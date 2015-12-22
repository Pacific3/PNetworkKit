
public typealias StartHandler = Operation -> Void
public typealias ProduceHandler = (Operation, NSOperation) -> Void
public typealias FinishHandler = (Operation, [NSError]) -> Void

public struct BlockOperationObserver: OperationObserver {
    private let startHandler: StartHandler?
    private let produceHandler: ProduceHandler?
    private let finishHandler: FinishHandler?
    
    public init(startHandler: StartHandler? = nil, produceHandler: ProduceHandler? = nil, finishHandler: FinishHandler? = nil) {
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    public func operationDidStart(operation: Operation) {
        startHandler?(operation)
    }
    
    public func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
        produceHandler?(operation, newOperation)
    }
    
    public func operationDidFinish(operation: Operation, errors: [NSError]) {
        finishHandler?(operation, errors)
    }
}
