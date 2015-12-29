
public class GetJSONModelOperation<T: JSONParselable>: GroupOperation {
    public var _downloadOperation: DownloadJSONOperation?
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
    
    public var cacheFile: NSURL {
        return cachesDirectory.URLByAppendingPathComponent("Cache\(self.dynamicType).json")
    }
    
    public var cachesDirectory: NSURL {
        do {
            return try! NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        }
    }
    
    public let query: [String:String]
    public let realmConfiguration: Realm.Configuration?
    
    private var hasProducedAlert = false
    
    public init(query q: [String:String], realmConfiguration c: Realm.Configuration? = nil, completion cf: Void -> Void) {
        query = q
        realmConfiguration = c
        
        super.init(operations: nil)
        
        let completion = NSBlockOperation(block: cf)
        
        parseOperation.addDependency(downloadOperation)
        completion.addDependency(parseOperation)
        
        addOperations([downloadOperation, parseOperation, completion])
        
        name = "\(self.dynamicType)"
    }
    
    public override func operationDidFinish(operation: NSOperation, withErrors errors: [NSError]) {
        if let firstError = errors.first where (operation === downloadOperation || operation === parseOperation) {
            produceAlert(firstError, hasProducedAlert: &hasProducedAlert) { generatedOperation in
                self.produceOperation(generatedOperation)
            }
        }
    }
}
