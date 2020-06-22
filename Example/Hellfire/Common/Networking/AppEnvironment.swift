//
//  AppEnvironment.swift
//  Hellfire
//
//  Created by Ed Hellyer on 11/01/17.
//  Copyright © 2017 Ed Hellyer. All rights reserved.
//

import Foundation

enum AppEnvironment: Int, Codable {
    
    case notSet = 0
    case developmentMainExternal
    case developmentReleExternal
    case testMainExternal
    case testReleExternal
    case productionExternal
    case customHost

    var description: String {
        switch self {
        case .notSet:
            return "Invalid Option"
        case .customHost:
            return "Custom Host"
        case .developmentMainExternal:
            return "Development Main External"
        case .developmentReleExternal:
            return "Development Release External"
        case .testMainExternal:
            return "Test Main External"
        case .testReleExternal:
            return "Test Release External"
        case .productionExternal:
            return "Production External"
        }
    }
    
    ///Gets the default environment.  The default environment depends on the selected scheme.
    static var buildDefaultEnvironment: AppEnvironment {
        get {
            #if DEVMAIN
                return AppEnvironment.developmentMainExternal
            #elseif DEVRELEASE
                return AppEnvironment.developmentReleExternal
            #elseif TESTMAIN
                return AppEnvironment.testMainExternal
            #elseif TESTRELEASE
                return AppEnvironment.testReleExternal
            #elseif PRODUCTION
                return AppEnvironment.productionExternal
            #else
                return AppEnvironment.developmentMainExternal
            #endif
        }
    }
}

