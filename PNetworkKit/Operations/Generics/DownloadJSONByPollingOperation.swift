
public class DownloadJSONByPollingOperation<T: Pollable, S: PollStateProtocol>: GroupOperation {
    // MARK: - Private Properties
    private var hasProducedAlert = false
    private var pollToURL: NSURL?
    private var pollState: S?
    private var __completion: T -> Void
    private var __error: NSError -> Void
    
    
    // MARK: - Public Properties
    public var initialDownloadOperation: DownloadJSONOperation? {
        return nil
    }
    
    public var pollingDownloadOperation: DownloadJSONOperation? {
        return nil
    }
    
    
    // MARK: - Public Initialisers
    public init(completion: T -> Void, error: NSError -> Void) {
        __completion = completion
        __error = error
        super.init(operations: nil)
        
        addSubOperations()
        
        name = "\(self.dynamicType)"
    }
    
    
    // MARK: - Overrides
    public override func operationDidFinish(
        operation: NSOperation,
        withErrors errors: [NSError]
        ) {
            if let firstError = errors.first where (operation === initialDownloadOperation || operation === pollingDownloadOperation) {
                __error(firstError)
                produceAlert(
                    firstError,
                    hasProducedAlert: &hasProducedAlert) { generatedOperation in
                        self.produceOperation(generatedOperation)
                }
                
                return
            }
            
            guard let operation = operation as? DownloadJSONOperation else {
                return
            }
            
            guard let json = operation.downloadedJSON,
                model = T.withData(json) else {
                    return
            }
            
            pollState = model.state as? S
            
            if pollState!.isPending() {
                pollToURL = NSURL(string: model.poll_to)
                self.addSubOperations()
            }
            else if pollState!.hasFinished() {
                __completion(model)
                finish(errors)
            }
    }
}


// MARK: - Private Methods
extension DownloadJSONByPollingOperation {
    private func addSubOperations() {
        guard let pollState = pollState else {
            return
        }
        
        let completion = NSBlockOperation(block: {})
        
        var _do: DownloadJSONOperation?
        
        if !pollState.hasStarted() {
            _do = initialDownloadOperation
        }
        else if pollState.hasStarted() && pollState.isPending() {
            _do = pollingDownloadOperation
            _do?.url = pollToURL
        }
        
        guard let op = _do else {
            return
        }
        
        completion.addDependency(op)
        
        addOperations([op, completion])
    }
}