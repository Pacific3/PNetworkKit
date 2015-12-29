
func produceAlert(error: NSError, inout hasProducedAlert: Bool, completion: Operation -> Void) {
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
    
    completion(alert)
    hasProducedAlert = true
}

private func ~=(lhs: (String, Int, String?), rhs: (String, Int, String?)) -> Bool {
    return lhs.0 ~= rhs.0 && lhs.1 ~= rhs.1 && lhs.2 == rhs.2
}

private func ~=(lhs: (String, OperationError, String), rhs: (String, Int, String?)) -> Bool {
    return lhs.0 ~= rhs.0 && lhs.1.rawValue ~= rhs.1 && lhs.2 == rhs.2
}
