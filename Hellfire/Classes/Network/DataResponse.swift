//
//  DataResponse.swift
//  Hellfire
//
//  Created by Ed Hellyer on 6/21/20.
//

import Foundation

public struct DataResponse {
    
    public let responseHeaders: [HTTPHeader]

    public let resposeBody: Data?
    
    public let statusCode: StatusCode
}
