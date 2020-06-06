//
//  ServiceError.swift
//  HellFire
//
//  Created by Ed Hellyer on 11/01/17.
//  Copyright © 2017 Ed Hellyer. All rights reserved.
//

import Foundation

public class ServiceError {
    
    public init(request: URLRequest, error: Error?, statusCode: StatusCode, responseBody: Data?) {
        self.request = request
        self.error = error
        self.statusCode = statusCode
        self.responseBody = responseBody
    }
    
    ///The url for the service error.
    public let request: URLRequest
    
    ///The error object (if there is one)
    public let error: Error?
    
    ///The status code can be a recognized HTTPStatusCode or one of this frameworks own network status code, defined in HTTPCode.
    public let statusCode: StatusCode
    
    ///The response body for the erroring request.
    public let responseBody: Data?
}
