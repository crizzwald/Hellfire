//
//  ServiceInterface+SharedInstance.swift
//  Pods
//
//  Created by Ed Hellyer on 5/26/20.
//

import Foundation

extension ServiceInterface {
    
    ///Lazily creates and returns a shared instance of ServiceInterface.  Use this when you only need one common instance of the service interface for the entire app.  (Most common 99.999% of the time.)
    public static var sharedInstance: ServiceInterface = {
        return ServiceInterface()
    }()
}
