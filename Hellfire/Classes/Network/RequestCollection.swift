//
//  RequestCollection.swift
//  HellFire
//
//  Created by Ed Hellyer on 2/12/19.
//  Copyright © 2019 Ed Hellyer. All rights reserved.
//

import Foundation

internal class RequestCollection {

    private var serialMessageQueue: DispatchQueue
    private var requests = [URLRequest: URLSessionTask]()
    private var taskIndex = [RequestTaskIdentifier: TaskRequestPair]()

    typealias TaskRequestPair = (task: URLSessionTask, request: URLRequest)

    init() {
        let queueLabel = "ThreadSafeMessageQueue." + String.randomString(length: 12)
        self.serialMessageQueue = DispatchQueue(label: queueLabel)
    }
    
    func removeTask(forRequest request: URLRequest) {
        self.serialMessageQueue.sync {
            if let key = self.requests.removeValue(forKey: request) {
                let _ = self.taskIndex.removeValue(forKey: key.taskIdentifier)
            }
        }
    }

    func removeRequest(forTask task: URLSessionTask) {
        self.serialMessageQueue.sync {
            if let key = self.taskIndex.removeValue(forKey: task.taskIdentifier) {
                let _ = self.requests.removeValue(forKey: key.request)
            }
        }
    }
    
    func add(request: URLRequest, task: URLSessionTask) {
        self.serialMessageQueue.sync {
            let _ = self.requests.updateValue(task, forKey: request)
            let _ = self.taskIndex.updateValue((task, request), forKey: task.taskIdentifier)
        }
    }
    
    func taskRequestPair(forIdentifier identifier: RequestTaskIdentifier) -> TaskRequestPair? {
        var taskRequestPair: TaskRequestPair? = nil
        self.serialMessageQueue.sync {
            taskRequestPair = self.taskIndex[identifier]
        }
        return taskRequestPair
    }
    
    func allTasks() -> [RequestTaskIdentifier] {
        let taskIdentifiers = self.taskIndex.compactMap { $0.key }
        return taskIdentifiers
    }
}
