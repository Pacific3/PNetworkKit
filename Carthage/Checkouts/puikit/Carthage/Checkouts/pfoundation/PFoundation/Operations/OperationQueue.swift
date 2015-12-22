/**
 Objects conforming to this protocol can respond to events on a `OperationQueue` instance.
 */
@objc protocol OperationQueueDelegate: NSObjectProtocol {
    /**
     This method is called when the `OperationQueue` instance is about to add
     a new operation it itself.
     - Parameter operationQueue: the `OperationQueue` instance that called this
     method.
     - Parameter operation: the `NSOperation` or `Operation` that is about to
     be added to the queue.
     */
    optional func operationQueue(operationQueue: OperationQueue, willAddOperation operation: NSOperation)
    
    /**
     This method is called when a `NSOperation` or `Operation` object finishes
     its execution within the `OperationQueue` instance.
     - Parameter operationQueue: the `OperationQueue` instance that called this
     method.
     - Parameter operation: The `NSOperation` or `Operation` that finished
     its execution within the `OperationQueue` instance.
     - Parameter errors: `NSError` array containing the errors (if any) that happened
     during the execution of the `NSOperation` or `Operation` instance that
     just finished its execution.
     */
    optional func operationQueue(operationQueue: OperationQueue, operationDidFinish operation: NSOperation, withErrors errors: [NSError])
}

/**
 `OperationQueue` is a generalization of `NSOperationQueue` that works with
 instances of `Operation`.
 
 To use `OperationQueue` you just need to call its designated initializer.
 
 ```swift
 let queue = OperationQueue()
 ```
 
 Then, you can add instances of `Operation` or `NSOperation` to it using the `addOperation(_:)` method.
 
 ```swift
 let op = Operation()
 queue.addOperation(op)
 ```
 
 - Attention:
 
 `OperationQueue` can also be used as a singleton.
 
 ```swift
 OperationQueue.sharedQueue.addOperation(op)
 ```
 */
public class OperationQueue: NSOperationQueue {
    /// Singleton object for `OperationQueue`. **Use carefully**.
    public static let sharedQueue = OperationQueue()
    
    /// The `OperationQueue`'s instance delegate.
    /// - SeeAlso: `protocol OperationQueueDelegate`
    weak var delegate: OperationQueueDelegate?
    
    override public func addOperation(operation: NSOperation) {
        if let op = operation as? Operation {
            let delegate = BlockOperationObserver(
                startHandler: nil,
                produceHandler: { [weak self] in
                    self?.addOperation($1)
                },
                finishHandler: {[weak self] in
                    if let q = self {
                        q.delegate?.operationQueue?(q, operationDidFinish: $0, withErrors: $1)
                    }
                }
            )
            op.addObserver(delegate)
            
            let dependencies = op.conditions.flatMap {
                $0.dependencyForOperation(op)
            }
            
            for dependency in dependencies {
                op.addDependency(dependency)
                addOperation(dependency)
            }
            
            let concurrencyCategories: [String] = op.conditions.flatMap { condition in
                if !condition.dynamicType.isMutuallyExclusive { return nil }
                
                return "\(condition.dynamicType)"
            }
            
            if !concurrencyCategories.isEmpty {
                let exclusivityController = RBExclusivityController.sharedInstance
                
                exclusivityController.addOperation(op, categories: concurrencyCategories)
                op.addObserver(BlockOperationObserver { operation, _ in
                    exclusivityController.removeOperation(operation, categories: concurrencyCategories)
                    })
            }
            
            op.willEnqueue()
        } else {
            operation.addCompletionBlock { [weak self, weak operation] in
                guard let queue = self, let operation = operation else { return }
                queue.delegate?.operationQueue?(queue, operationDidFinish: operation, withErrors: [])
            }
        }
        
        delegate?.operationQueue?(self, willAddOperation: operation)
        super.addOperation(operation)
    }
    
    override public func addOperations(ops: [NSOperation], waitUntilFinished wait: Bool) {
        for operation in operations {
            addOperation(operation)
        }
        
        if wait {
            for operation in operations {
                operation.waitUntilFinished()
            }
        }
    }
    
    public override init() { }
}
