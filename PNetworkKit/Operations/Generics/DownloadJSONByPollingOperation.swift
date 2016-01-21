public protocol Clonable {
    func clone() -> Self?
}

public class DownloadJSONByPollingOperation<T: Pollable, P: DownloadJSONOperation where P: Clonable>: GroupOperation {
    // MARK: - Private Properties
    private var hasProducedAlert = false
    private var pollToURL: NSURL?
    private var pollState: PollStateProtocol?
    private var __completion: T -> Void
    private var __error: NSError -> Void
    private var model: T?
    
    
    // MARK: - Public Properties
    public var initialDownloadOperation: DownloadJSONOperation
    public var pollingDownloadOperation: P
    
    
    // MARK: - Public Initialisers
    public init(
        initialDownload: DownloadJSONOperation,
        pollOperation: P,
        completion: T -> Void,
        error: NSError -> Void,
        initialPollState: PollStateProtocol
        ) {
            __completion = completion
            __error = error
            pollState = initialPollState
            initialDownloadOperation = initialDownload
            pollingDownloadOperation = pollOperation
            
            super.init(operations: nil)
            
            addSubOperations()
            
            name = "\(self.dynamicType)"
    }
    
    
    // MARK: - Overrides
    public override func finish(errors: [NSError]) {
        if pollState!.hasFinished() {
            print("finished")
            if let _m = model {
                __completion(_m)
            }
            
            internalQueue.suspended = true
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
                __error(firstError)
                produceAlert(
                    firstError,
                    hasProducedAlert: &hasProducedAlert) { generatedOperation in
                        self.produceOperation(generatedOperation)
                }
                
                return
            }
            
            guard let operation = operation as? DownloadJSONOperation else {
                print("not equal")
                return
            }
            
            print("\(operation.name): \(operation.downloadedJSON)")
            
            guard let json = operation.downloadedJSON else {
                return
            }
            
            model = T.withData(json)
            
            guard let _m = model else {
                return
            }
            
            pollState = _m.state
            
            if pollState!.isPending() {
                pollToURL = NSURL(string: _m.poll_to)
                self.addSubOperations()
            }
            else if pollState!.hasFinished() {
                finish(errors)
            }
    }
}


// MARK: - Private Methods
extension DownloadJSONByPollingOperation {
    private func addSubOperations() {
        internalQueue.maxConcurrentOperationCount = 1
        guard let pollState = pollState else {
            return
        }
        
        let completion = NSBlockOperation(block: {})
        
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
            print("internalqueue suspended: \(internalQueue.suspended)")
            print("operation finished: \(_do?.finished)")
            print("new poll url: \(_do?.url)")
        }
        
        guard let op = _do else {
            return
        }
        
        completion.addDependency(op)
        
        addOperations([op, completion])
    }
}