public protocol Clonable {
    func clone() -> Self?
}

public class DownloadJSONByPollingOperation<T: Pollable, P: DownloadJSONOperation where P: Clonable>: GroupOperation {
    // MARK: - Private Properties
    private var hasProducedAlert = false
    private var pollToURL: NSURL?
    private var pollState: PollStatusProtocol
    public var __completion: (T -> Void)?
    // WARNING: __completion and _error are ugly
    public var __error: (NSError -> Void)?
    private var model: T?
    
    
    // MARK: - Public Properties
    public var initialDownloadOperation: DownloadJSONOperation
    public var pollingDownloadOperation: P
    public var parsedJSON: T?
    
    // MARK: - Public Initialisers
    public init(
        initialDownload: DownloadJSONOperation,
        pollOperation: P,
        completion: (T -> Void)? = nil,
        error: (NSError -> Void)? = nil,
        initialPollState: PollStatusProtocol
        ) {
            __completion = completion
            __error = error
            pollState = initialPollState
            initialDownloadOperation = initialDownload
            pollingDownloadOperation = pollOperation
            
            super.init(operations: nil)
            
            name = "\(self.dynamicType)"
            
            addSubOperations()
    }
    
    
    // WARNING: Something crashes after the response is delivered back to the caller
    // MARK: - Overrides
    public override func finish(errors: [NSError]) {
        if pollState.hasFinished() {
            if let _m = model {
                parsedJSON = _m
                __completion?(_m)
            }
            super.finish(errors)
        } else {
            internalQueue.suspended = false
        }
    }
    
    public override func operationDidFinish(
        operation: NSOperation,
        withErrors errors: [NSError]
        ) {
            let initial = initialDownloadOperation
            let polling = pollingDownloadOperation
            
            if let firstError = errors.first where (operation.name == initial.name || operation.name == polling.name) {
                __error?(firstError)
                produceAlert(
                    firstError,
                    hasProducedAlert: &hasProducedAlert) { generatedOperation in
                        self.produceOperation(generatedOperation)
                }
                
                return
            }
            
            if let operation = operation as? DownloadJSONOperation where (operation.name == pollingDownloadOperation.name || operation.name == initialDownloadOperation.name) {
                guard
                    let json = operation.downloadedJSON,
                    result = json["result"] as? [String:AnyObject]
                    else {
                        return
                }
                
                model = T.withData(result)
                
                guard let _m = model else {
                    return
                }
                
                pollState = _m.state
                
                if pollState.isPending() {
                    pollToURL = NSURL(string: _m.poll_to)
                    self.addSubOperations()
                }
                else if pollState.hasFinished() {
                    finish(errors)
                }
            }
    }
}


// MARK: - Private Methods
extension DownloadJSONByPollingOperation {
    private func addSubOperations() {
        let completion = NSBlockOperation(block: {})
        completion.name = "Completion Block"
        
        var _do: DownloadJSONOperation?
        
        if !pollState.hasStarted() {
            _do = initialDownloadOperation
        }
        else if pollState.isPending() {
            guard let clone = pollingDownloadOperation.clone() else {
                return
            }
            
            _do = clone
            _do?.url = pollToURL
        }
        
        guard let op = _do else {
            return
        }
        
        completion.addDependency(op)
        
        addOperations([op, completion])
    }
}