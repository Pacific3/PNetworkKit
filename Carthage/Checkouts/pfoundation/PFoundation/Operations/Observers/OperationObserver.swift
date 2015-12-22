
public protocol OperationObserver {
    func operationDidStart(operation: Operation)
    func operation(operation: Operation, didProduceOperation newOperation: NSOperation)
    func operationDidFinish(operation: Operation, errors: [NSError])
}
