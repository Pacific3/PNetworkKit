
/**
 `GroupOperation` is a subclass of `Operation` that represents a group of
 `Operations` that together repesent a whole operation.
 */
public class GroupOperation: Operation {
    public let internalQueue = OperationQueue()
    private let startingOperation = NSBlockOperation(block: {})
    private let finishingOperation = NSBlockOperation(block: {})
    
    private var aggregatedErrors = [NSError]()
    
    convenience public init(operations: NSOperation...) {
        self.init(operations: operations)
    }
    
    /**
     Designated initializer that takes an array of `NSOperation`s and adds them
     to an internal `OperationQueue` instance that is in a "suspended" state.
     
     The `NSOperation`s in the internal queue won't start executing until the
     `GroupOperation` instance is added to an instance of `OperationQueue`
     itself.
     */
    public init(operations: [NSOperation]? = nil) {
        super.init()
        
        prepare()
        if let ops = operations {
            addOperations(ops)
        }
    }
    
    private func prepare() {
        internalQueue.suspended = true
        internalQueue.delegate = self
        internalQueue.addOperation(startingOperation)
    }
    
    /// Cancels all the operations on the internal queue.
    override public func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
    }
    
    override public func execute() {
        internalQueue.suspended = false
        internalQueue.addOperation(finishingOperation)
    }
    
    public func addOperation(operation: NSOperation) {
        internalQueue.addOperation(operation)
    }
    
    public final func aggregateError(error: NSError) {
        aggregatedErrors.append(error)
    }
    
    public func operationDidFinish(operation: NSOperation, withErrors errors: [NSError]) {
        // Subclassing!
    }
    
    public func addOperations(operations: [NSOperation]) {
        for operation in operations {
            internalQueue.addOperation(operation)
        }
    }
}

extension GroupOperation: OperationQueueDelegate {
    final func operationQueue(operationQueue: OperationQueue, willAddOperation operation: NSOperation) {
        assert(!finishingOperation.finished && !finishingOperation.executing, "Cannot add new operations to a group after the group hasc completed!")
        
        if operation !== finishingOperation {
            finishingOperation.addDependency(operation)
        }
        
        if operation !== startingOperation {
            operation.addDependency(startingOperation)
        }
    }
    
    final func operationQueue(operationQueue: OperationQueue, operationDidFinish operation: NSOperation, withErrors errors: [NSError]) {
        aggregatedErrors.appendContentsOf(errors)
        
        if operation === finishingOperation {
            internalQueue.suspended = true
            finish(aggregatedErrors)
        } else if operation !== startingOperation {
            operationDidFinish(operation, withErrors: errors)
        }
    }
}
