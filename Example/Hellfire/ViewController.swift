//
//  ViewController.swift
//  Hellfire
//
//  Created by Ed Hellyer on 11/01/17.
//  Copyright © 2017 Ed Hellyer. All rights reserved.
//

import UIKit
import Hellfire

class ViewController: UIViewController {

    @IBAction func executeButton_TouchUp(_ sender: UIButton) {
        print(self.serviceInterface)
        self.fetchPosts()
        self.fetchUsers()
        
        
    }
    
    var serviceInterface: ServiceInterface {
        return (UIApplication.shared.delegate as! AppDelegate).serviceInterface
    }
    
    private func fetchPosts() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/comments")!
        let request = DataRequest(url: url, method: .get)
        let _ = self.serviceInterface.executeDataTask(forRequest: request) { (data, error, statusCode) in
            if let t = [Post].initialize(jsonData: data) {
                print("Item Count: \(t.count)")
                print(t[0])
            }
        }
    }
    
    private func fetchUsers() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        let request = DataRequest(url: url, method: .get)
        let _ = self.serviceInterface.executeDataTask(forRequest: request) { (data, error, statusCode) in
            if let t = [User].initialize(jsonData: data) {
                print("Item Count: \(t.count)")
                print(t[0])
            }
        }
    }
    
}

