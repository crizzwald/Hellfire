//
//  DataRequest.swift
//  HellFire
//
//  Created by Ed Hellyer on 11/01/17.
//  Copyright © 2017 Ed Hellyer. All rights reserved.
//

import Foundation

///The basic request object supplying the minimal information for a network request.  Headers are set later by a call to the ServiceInterfaceSessionDelegate.
public struct DataRequest {
    
    public init(url: URL,
                method: HTTPMethod,
                cachePolicyType: CachePolicyType = .doNotCache,
                timeoutInterval: TimeInterval = TimeInterval(50),
                httpBody: Data? = nil,
                contentType: String = "application/json") {
        self.url = url
        self.method = method
        self.cachePolicyType = cachePolicyType
        self.timeoutInterval = timeoutInterval
        self.httpBody = httpBody
        self.contentType = contentType
    }
    
    /// Gets the url object.
    public let url: URL
    
    /// Gets the HTTP method
    public let method: HTTPMethod
    
    /// Gets the CachePolicyType.
    public let cachePolicyType: CachePolicyType
    
    /// Gets the timeout setting for the request in seconds.  Default is 50 seconds if left nil.
    public let timeoutInterval: TimeInterval
    
    /// Gets the Request http body
    public let httpBody: Data?
    
    /// Gets the content type.
    public let contentType: String
}
