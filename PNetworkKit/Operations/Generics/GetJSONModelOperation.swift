//
//  GetJSONModelOperation.swift
//  reserbus-ios
//
//  Created by Swanros on 8/24/15.
//  Copyright © 2015 Reserbus S. de R.L. de C.V. All rights reserved.
//

public class GetJSONModelOperation<T: JSONParselable>: GroupOperation {
    internal var _downloadOperation: DownloadJSONOperation?
    internal var _parseOperation: ParseJSONOperation<T>?
    
    var downloadOperation: DownloadJSONOperation {
        if let op = _downloadOperation { return op } else {
            _downloadOperation = DownloadJSONOperation(cacheFile: cacheFile)
            
            return _downloadOperation!
        }
    }
    
    var parseOperation: ParseJSONOperation<T> {
        if let op = _parseOperation { return op } else {
            _parseOperation = ParseJSONOperation<T>(cacheFile: cacheFile)
            
            return _parseOperation!
        }
    }
    
    var cacheFile: NSURL {
        return cachesDirectory.URLByAppendingPathComponent("Cache\(self.dynamicType).json")
    }
    
    var cachesDirectory: NSURL {
        do {
            return try! NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        }
    }
    
    let query: [String:String]
    let realmConfiguration: Realm.Configuration?
    
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
            produceAlert(firstError)
        }
    }
    
    private func produceAlert(error: NSError) {
        if hasProducedAlert { return }
        
        let alert = ShowAlertOperation()
        let errorReason = (error.domain, error.code, error.userInfo[OperationConditionKey] as? String)
        
        let failedReachability = (ErrorDomain, OperationError.ConditionFailed, ReachabilityCondition.name)
        let failedJson = (NSCocoaErrorDomain, NSPropertyListReadCorruptError, nil as String?)
        
        switch errorReason {
        case failedReachability:
            let hostUrl = error.userInfo[ReachabilityCondition.hostKey] as! NSURL
            alert.title = "Unable to Connect"
            alert.message  = "Cannot connect to \(hostUrl.host!). Make sure your device is connected to the internet."
            
        case failedJson:
            alert.title = "Unable to Download"
            alert.message = "Cannot download data. Try again later."
            
        default:
            return
        }
        
        produceOperation(alert)
        hasProducedAlert = true
    }
}

private func ~=(lhs: (String, Int, String?), rhs: (String, Int, String?)) -> Bool {
    return lhs.0 ~= rhs.0 && lhs.1 ~= rhs.1 && lhs.2 == rhs.2
}

private func ~=(lhs: (String, OperationError, String), rhs: (String, Int, String?)) -> Bool {
    return lhs.0 ~= rhs.0 && lhs.1.rawValue ~= rhs.1 && lhs.2 == rhs.2
}
