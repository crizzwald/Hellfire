//
//  ServiceRoutes.swift
//  Hellfire
//
//  Created by Ed Hellyer on 11/01/17.
//  Copyright © 2017 Ed Hellyer. All rights reserved.
//

import Foundation

struct ServiceRoutes {
    struct JSONPlaceholder {
        ///Generate the auth and refresh token from the username and password.
        static let users = "users"
        
        ///Refresh the auth token from the refresh token.
        static let comments = "comments"
    }
}
