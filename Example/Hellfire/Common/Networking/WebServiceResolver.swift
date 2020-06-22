//
//  WebServiceResolver.swift
//  Hellfire
//
//  Created by Ed Hellyer on 11/01/17.
//  Copyright © 2017 Ed Hellyer. All rights reserved.
//

import Foundation

class WebServiceResolver {
    
    //MARK: - WebServiceResolver Life Cycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        #if DEBUG
        print("\(String(describing: type(of: self))) has deallocated. - \(#function)")
        #endif
    }
    
    init() {
        //Reload the config - This ensures ANY INSTANCE of WebServiceResolver will load updated custom config changes.
//        NotificationCenter.default.addObserver(forName: AppNotificationKeys.hostOrProtocolChangedNotification, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
//            guard let strongSelf = self else { return }
//            let serviceCollection = ServiceHostCollection(serviceConfig: strongSelf.serviceConfig)
//            strongSelf.serviceHostCollection = serviceCollection
//        }
    }

    //MARK: - Private API
    
    
    private let lastUsedHostEnvironmentId = "LastUsedEnvironmentKey"
    
    ///Gets the default service configurations for environments from config file.
    private lazy var serviceConfig: ServiceConfig = ServiceConfig()
    
    ///Gets the currently selected service host.
    private var selectedServiceHost: ServiceHost {
        get {
            let envToUse = (self.userSwitchedEnvironment != AppEnvironment.notSet) ? self.userSwitchedEnvironment : AppEnvironment.buildDefaultEnvironment
            var serviceHost = self.serviceHostCollection.serviceHost(forEnvironment: envToUse)
            if serviceHost == nil {
                serviceHost = self.serviceHostCollection.serviceHost(forEnvironment: AppEnvironment.buildDefaultEnvironment)
            }
            return serviceHost!
        }
    }
    
    ///Gets the service host collection by unpacking the default service configuration from config file.
    private lazy var serviceHostCollection: ServiceHostCollection = {
        var hostCollection = ServiceHostCollection(serviceConfig: self.serviceConfig)
        return hostCollection
    }()
    
    ///Gets the user selected environment or returns ParentAppEnvironment.notSet, if we are using the default environment for the build config.
    private var userSwitchedEnvironment: AppEnvironment {
        get {
            if let hostEnvironmentId = UserDefaults.standard.object(forKey: self.lastUsedHostEnvironmentId) as? Int, let hostEnvironment = AppEnvironment(rawValue: hostEnvironmentId) {
                return hostEnvironment
            } else {
                return AppEnvironment.notSet
            }
        }
    }
    
    private func stopAllFetches() {
        //ServiceInterface.sharedInstance.cancelAllCurrentRequests()
    }
    
    private func postNotificationForHostOrProtocolChange() {
        NotificationCenter.default.post(name: AppNotificationKeys.hostOrProtocolChangedNotification, object: nil)
    }
    
    //MARK: - Public API
    
    ///Gets the key string used to return the custom host information from UserDefaults.
    let customHostConfiguration = "customHostConfiguration"
    
    ///Gets the full host path for selected environment
    var fullHost: String {
        return self.selectedServiceHost.fullServiceHost
    }
    
    ///Gets the current host
    var host: String {
        get {
            return self.selectedServiceHost.host
        }
    }
    
    ///Gets the current environment in use.
    var currentEnvironment: AppEnvironment {
        get {
            return self.selectedServiceHost.environment
        }
    }
    
    ///Returns the full url for the specified route based on the current service host configuration.
    func url(forRoute route: String) -> URL {
        var url = URL(string: self.selectedServiceHost.fullServiceHost)
        url = url?.appendingPathComponent(route)
        return url!
    }
    
    ///Returns the full url for the specified route based on the current service host configuration as a URL components so that parameters can be appended to it.
    func urlComponents(forRoute route: String) -> URLComponents {
        var url = URL(string: self.selectedServiceHost.fullServiceHost)
        url = url?.appendingPathComponent(route)
        let urlComponents = URLComponents(string: url!.absoluteString)
        return urlComponents!
    }
    
    ///Returns the service host for the specifed environment.
    func serviceHost(forEnvironment environment: AppEnvironment?) -> ServiceHost? {
        let env = environment ?? self.currentEnvironment
        let serviceHost = self.serviceHostCollection.serviceHost(forEnvironment: env)
        return serviceHost
    }
    
    ///Updates the selected environment for the app and posts a notification to signal the change.
    func updateSelected(environment: AppEnvironment) {
        if (self.selectedServiceHost.environment != environment || environment == .customHost) {
            self.stopAllFetches()
            UserDefaults.standard.set(environment.rawValue, forKey: self.lastUsedHostEnvironmentId)
            self.postNotificationForHostOrProtocolChange()
        }
    }
    
    ///Updates the custom host configuration
    func saveCustomConfiguration(serviceHost: ServiceHost) {
        var customHost = serviceHost
        customHost.environment = .customHost
        
        //Update the collection in memory
        self.serviceHostCollection.updateCustomHost(serviceHost: customHost)
        
        //Save to disk to persist the change
        if let jsonData = try? JSONEncoder().encode(customHost) {
            UserDefaults.standard.set(jsonData, forKey: self.customHostConfiguration)
        }
    }
}
