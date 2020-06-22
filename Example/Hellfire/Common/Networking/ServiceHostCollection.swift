//
//  ServiceHostCollection.swift
//  Hellfire
//
//  Created by Ed Hellyer on 11/01/17.
//  Copyright © 2017 Ed Hellyer. All rights reserved.
//

import Foundation

class ServiceHostCollection {
    
    init(serviceConfig: ServiceConfig ) {
        self.items = serviceConfig.services
        
        if let customHost = self.customHostDefinition() {
            self.updateCustomHost(serviceHost: customHost)
        }
    }
    
    //MARK: - Private API
    
    private func customHostDefinition() -> ServiceHost? {
        var customHost: ServiceHost?

        //Try to unpack the custom host if it has been created on this device.
        if let jsonData = UserDefaults.standard.data(forKey: AppUserKeys.customHostConfiguration) {
            customHost = try? JSONDecoder().decode(ServiceHost.self, from: jsonData)
        }

        //Return the default from the config if nil
        if customHost == nil {
            customHost = self.serviceHost(forEnvironment: .customHost)
        }

        return customHost
    }
    
    //MARK: - Public API
    
    
    var items: [ServiceHost] = []
    
    func serviceHost(forEnvironment envionment: AppEnvironment) -> ServiceHost? {
        let serviceHost = self.items.filter { $0.environment == envionment }.first
        return serviceHost
    }
    
    func updateCustomHost(serviceHost: ServiceHost) {
        if let index = self.items.firstIndex(where: { $0.environment == .customHost }) {
            self.items[index] = serviceHost
            //Allow passing in non-custom host, but we'll force to custom.
            self.items[index].environment = .customHost
        }
    }
}
