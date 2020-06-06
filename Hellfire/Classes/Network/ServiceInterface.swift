//
//  ServiceInterface.swift
//  HellFire
//
//  Created by Ed Hellyer on 11/01/17.
//  Copyright © 2017 Ed Hellyer. All rights reserved.
//

import Foundation

public typealias RequestTaskIdentifier = Int
public typealias DataTaskCompletion = (_ response: Data?, _ error: Error?, _ statusCode: StatusCode) -> Void
public typealias ReachabilityHandler = (_ reachabilityStatus: ReachabilityStatus) -> Void
public typealias ServiceErrorHandler = (_ serviceError: ServiceError) -> Void

//Only one instance per app should be created.  However, rather than trying to enforce this via a singleton, its up to the app developer when to create multiple instances.  But be aware that DiskCache is still shared between all instances.  Although a unique hash insertion key will be created, storage size will be shared.
public class ServiceInterface {
    
    //MARK: - Private API
    
    private var reachabilityManager: NetworkReachabilityManager?
    private var privateReachabilityHost: String?
    private lazy var requestCollection = RequestCollection()
    private lazy var diskCache = DiskCache.shared()
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: configuration)
        return urlSession
    }()
    
    private func statusCodeForResponse(_ response: HTTPURLResponse?, error: Error?) -> StatusCode {
        //We decided we always want to have a value in statusCode.  This means that for non-service errors, we set the statusCode to negative values that are not recognized in the industry.
        let defaultStatusCode = (error == nil) ? HTTPCode.ok.rawValue : HTTPCode.generalError.rawValue
        var statusCode: Int = response?.statusCode ?? defaultStatusCode

        if let _error = error as NSError?, HTTPCode.isOk(statusCode: statusCode) == false {
            if (_error.code == HTTPCode.userCancelledRequest.rawValue) {
                statusCode = HTTPCode.userCancelledRequest.rawValue
            } else if (_error.code == HTTPCode.connectionMakeTimeout.rawValue) {
                statusCode = HTTPCode.connectionMakeTimeout.rawValue
            } else if (_error.code == HTTPCode.unableToCreateSSLSession.rawValue) {
                statusCode = HTTPCode.unableToCreateSSLSession.rawValue
            } else if (_error.code == HTTPCode.hostNameNotFound.rawValue) {
                statusCode = HTTPCode.hostNameNotFound.rawValue
            }
        }

        return statusCode
    }

    private func checkReponse(data: Data?, response: HTTPURLResponse?, error: Error?, fromRequest request: URLRequest) {
        let statusCode = self.statusCodeForResponse(response, error: error)
        if HTTPCode.isOk(statusCode: statusCode) { return }
        let serviceError = ServiceError(request: request, error: error, statusCode: statusCode, responseBody: data)
        self.serviceErrorHandler?(serviceError)
    }
    
    private func urlRequest(fromDataRequest request: DataRequest) -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.name
        urlRequest.httpBody = request.httpBody
        urlRequest.timeoutInterval = request.timeoutInterval
        
        //Ask session delegate for any headers for this request.
        if let headers = self.sessionDelegate?.headerCollection(forRequest: request) {
            headers.forEach({ (header) in
                urlRequest.setValue(header.value, forHTTPHeaderField: header.name)
            })
        }
        
        return urlRequest
    }
    
    private func isCachedResponse(forRequest request: DataRequest, completion: @escaping DataTaskCompletion) -> Bool {
        if request.cachePolicyType != CachePolicyType.doNotCache {
            if let response = self.diskCache.getCacheDataFor(request: request) {
                DispatchQueue.main.async {
                    completion(response, nil, HTTPCode.ok.rawValue)
                }
                return true
            }
        }
        return false
    }

    //MARK: - Public API
    
    deinit {
        #if DEBUG
        print("\(String(describing: type(of: self))) has deallocated. - \(#function)")
        #endif
    }

    public init() {
        
    }
    
    ///Gets or sets the handler for the reachability status change events.
    public var reachabilityHandler: ReachabilityHandler?
    
    ///Gets or sets the handler for the service error handler
    public var serviceErrorHandler: ServiceErrorHandler?
    
    /**
     Gets or sets the reachability host (e.g. "www.apple.com").
     Setting the host to some value starts the listener.
     Setting the host to nil will stop the listener.
     IMPORTANT NOTE: You must set self.reachabilityHost after setting self.reachabilityHandler, otherwise reachability manager will not start listening for network change events.
     */
    public var reachabilityHost: String? {
        get {
            return self.privateReachabilityHost
        }
        set {
            self.privateReachabilityHost = newValue
            self.reachabilityManager?.stopListening()
            self.reachabilityManager?.listener = nil
            
            if ((newValue ?? "").isEmpty == false && self.reachabilityHandler != nil) {
                self.reachabilityManager = NetworkReachabilityManager(host: newValue!)
                self.reachabilityManager?.listener = { [weak self] status in
                    guard let strongSelf = self else { return }
                    switch status {
                    case .notReachable:
                        strongSelf.reachabilityHandler?(.notReachable)
                    case .unknown :
                        strongSelf.reachabilityHandler?(.unknown)
                    case .reachable(.ethernetOrWiFi):
                        strongSelf.reachabilityHandler?(.reachable(.wiFiOrEthernet))
                    case .reachable(.wwan):
                        strongSelf.reachabilityHandler?(.reachable(.cellular))
                    }
                }
                self.reachabilityManager?.startListening()
            }
        }
    }
    
    public weak var sessionDelegate: ServiceInterfaceSessionDelegate?
    
    public func executeDataTask(forRequest request: DataRequest, completion: @escaping DataTaskCompletion) -> RequestTaskIdentifier? {

        if isCachedResponse(forRequest: request, completion: completion) { return nil }
        
        let urlRequest = self.urlRequest(fromDataRequest: request)
        let task = self.session.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let strongSelf = self else { return }
            let httpURLResponse = response as? HTTPURLResponse
            
            //Get the status code that best represents this reponse
            let statusCode = strongSelf.statusCodeForResponse(httpURLResponse, error: error)
            
            //Store response in disk cache.  DiskCache checks cachePolicyType to see if it should indeed cache response data.
            if let responseData = data {
                strongSelf.diskCache.cache(data: responseData, forRequest: request)
            }
            
            //Send back response headers (In the future the headers will be additionally included with the response.)
            strongSelf.sessionDelegate?.responseHeaders(headers: httpURLResponse?.allHeaderFields)
            
            ///Check for error in the response.
            strongSelf.checkReponse(data: data, response: httpURLResponse, error: error, fromRequest: urlRequest)
            
            //Remove request \ task from executing tasks collection
            strongSelf.requestCollection.removeTask(forRequest: urlRequest)
            
            //Call completion block
            DispatchQueue.main.async {
                completion(data, error, statusCode)
            }
        }
        
        self.requestCollection.add(request: urlRequest, task: task)
        task.resume()
        
        return task.taskIdentifier
    }
    
    public func cancelRequest(taskIdentifier: RequestTaskIdentifier?) {
        guard let taskId = taskIdentifier else { return }
        if let taskRequestPair = self.requestCollection.taskRequestPair(forIdentifier: taskId) {
            taskRequestPair.task.cancel()
            self.requestCollection.removeTask(forRequest: taskRequestPair.request)
        }
    }
    
    public func cancelAllCurrentRequests() {
        let tasks = self.requestCollection.allTasks()
        tasks.forEach { (task) in
            self.cancelRequest(taskIdentifier: task)
        }
    }
}
