
public class GetJSONModelByPollingOperation<T: Object where T: Pollable>: GroupOperation {
    public var _downloadOperation: DownloadJSONOperation?
    public var _pollOperation: DownloadJSONOperation?
    public var _parseOperation: ParseJSONOperation<T>?
    
    public var downloadOperation: DownloadJSONOperation {
        if let op = _downloadOperation { return op } else {
            _downloadOperation = DownloadJSONOperation(cacheFile: cacheFile)
            
            return _downloadOperation!
        }
    }
    
    public var parseOperation: ParseJSONOperation<T> {
        if let op = _parseOperation { return op } else {
            _parseOperation = ParseJSONOperation<T>(cacheFile: cacheFile)
            
            return _parseOperation!
        }
    }
    
    public var pollOperation: DownloadJSONOperation {
        if let po = _pollOperation { return po } else {
            _pollOperation = DownloadJSONOperation(cacheFile: cacheFile, url: pollURL)
            
            return _pollOperation!
        }
    }
    
    public var pollURL: NSURL?
    public var pollingState: PollState = .Pending
    public var completion: (Void -> Void)?
    
    public var cacheFile: NSURL {
        return cachesDirectory.URLByAppendingPathComponent("Cache\(self.dynamicType).json")
    }
    
    public var cachesDirectory: NSURL {
        do {
            return try! NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        }
    }
    
    public let realmConfiguration: Realm.Configuration?
    
    private var hasProducedAlert = false
    
    public init(realmConfiguration: Realm.Configuration? = nil, completion: Void -> Void) {
        self.realmConfiguration = realmConfiguration
        self.completion = completion
        
        super.init(operations: nil)
        
        addSuboperations()
        
        name = "\(self.dynamicType)"
    }
    
    private func addSuboperations() {
        _parseOperation = nil
        _pollOperation = nil
        
        let completion = NSBlockOperation(block: {})
        
        var _do: Operation
        
        if _downloadOperation == nil {
            _do = downloadOperation
        } else {
            _do = pollOperation
        }
        
        parseOperation.addDependency(_do)
        completion.addDependency(parseOperation)
        
        addOperations([_do, parseOperation, completion])
    }
    
    public override func finish(errors: [NSError]) {
        if pollingState == .Finished {
            completion?()
            internalQueue.suspended = true
            super.finish(errors)
        } else {
            internalQueue.suspended = false
        }
    }
    
    public override func operationDidFinish(operation: NSOperation, withErrors errors: [NSError]) {
        if let firstError = errors.first where (operation === downloadOperation || operation === parseOperation) {
            produceAlert(firstError, hasProducedAlert: &hasProducedAlert) { generatedOperation in
                self.produceOperation(generatedOperation)
            }
            
            return
        }
        
        if operation == parseOperation {
            guard let realmConfiguration = realmConfiguration else {
                return
            }
            let realm = try! Realm(configuration: realmConfiguration)
            
            guard let container = realm.objects(T).flatMap({ $0 }).first else {
                return
            }
            
            pollingState = container.state
            
            switch pollingState {
            case .Pending:
                pollURL = NSURL(string: container.poll_to)!
                self.addSuboperations()
                
            case .Finished:
                finish(errors)
                break
            }
        }
    }
}
