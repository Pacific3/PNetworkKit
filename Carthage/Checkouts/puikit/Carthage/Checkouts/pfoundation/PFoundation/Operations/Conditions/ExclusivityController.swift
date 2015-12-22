//
//  RBExclusivityController.swift
//  reserbus-ios
//
//  Created by Swanros on 8/14/15.
//  Copyright © 2015 Reserbus S. de R.L. de C.V. All rights reserved.
//

private let ExclusivityControllerSerialQueueLabel = "Operations.ExclusivityController"

class RBExclusivityController {
    static let sharedInstance = RBExclusivityController()
    
    private let serialQueue = dispatch_queue_create(ExclusivityControllerSerialQueueLabel, DISPATCH_QUEUE_SERIAL)
    private var operations: [String: [Operation]] = [:]
    
    private init() {}
    
    func addOperation(operation: Operation, categories: [String]) {
        dispatch_sync(serialQueue) {
            for category in categories {
                self.noqueue_addOperation(operation, category: category)
            }
        }
    }
    
    func removeOperation(operation: Operation, categories: [String]) {
        dispatch_async(serialQueue) {
            for category in categories {
                self.noqueue_removeOperation(operation, category: category)
            }
        }
    }
    
    private func noqueue_addOperation(operation: Operation, category: String) {
        var operationsWithThisCategory = operations[category] ?? []
        
        if let last = operationsWithThisCategory.last {
            operation.addDependency(last)
        }
        
        operationsWithThisCategory.append(operation)
        operations[category] = operationsWithThisCategory
    }
    
    private func noqueue_removeOperation(operation: Operation, category: String) {
        let matchingOperations = operations[category]
        
        if var operationsWithThisCategory = matchingOperations,
            let index = operationsWithThisCategory.indexOf(operation) {
                operationsWithThisCategory.removeAtIndex(index)
                operations[category] = operationsWithThisCategory
        }
    }
}
