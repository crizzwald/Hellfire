//
//  NetworkResponse.swift
//  Hellfire
//
//  Created by Ed Hellyer on 6/21/20.
//

import Foundation

///Describes the successful response of an HTTP \ HTTPS call to a server
public struct NetworkResponse {
    
    ///Gets the headers from the server response.
    public let responseHeaders: [HTTPHeader]

    ///Gets the body from the server response
    public let body: Data?
    
    ///Gets the HTTP result status code
    public let statusCode: StatusCode
}
