//
//  ServiceHost.swift
//  Hellfire
//
//  Created by Ed Hellyer on 11/01/17.
//  Copyright © 2017 Ed Hellyer. All rights reserved.
//

import Foundation

struct ServiceHost: Codable {
    
    init (environment: AppEnvironment,
          procol: String,
          host: String,
          hostPort: Int? = nil,
          hostPath: String? = nil) {
        self.environment = environment
        self.procol = procol
        self.host = host
        self.hostPort = hostPort
        self.hostPath = hostPath
    }
    
    ///Gets or sets the host environment for the current configuration.
    var environment: AppEnvironment
    
    ///Gets or sets the protocol currently in use.  (e.g. http, https)
    var procol: String
    
    ///Gets or sets the host currently in use.  (e.g. sever.domain.com)
    var host: String
    
    ///Gets or sets the port the host is listening on.  Default is nil which will in turn cause the defult port for the protocol.
    var hostPort: Int? = nil
    
    ///Gets or sets the hosts static relative path currently in use. (e.g. http://server.domain.com/<hostpath> )
    var hostPath: String? = nil
    
    ///Gets the assembled string that represents the protocol, host, port and host path. (e.g.  http://server.domain.com:1234/hostpath )
    var fullServiceHost: String {
        get {
            let port = (self.hostPort != nil) ? ":\(hostPort!)" : ""
            let hostPath = (self.hostPath != nil) ? "\(self.hostPath!)/" : ""
            let srvHost = "\(self.procol)://\(self.host)\(port)/\(hostPath)"
            return srvHost
        }
    }
}
