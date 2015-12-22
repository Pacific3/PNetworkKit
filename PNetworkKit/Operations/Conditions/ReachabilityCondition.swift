//
//  ReachabilityCondition.swift
//  reserbus-ios
//
//  Created by Swanros on 8/18/15.
//  Copyright © 2015 Reserbus S. de R.L. de C.V. All rights reserved.
//

import SystemConfiguration

struct ReachabilityCondition: OperationCondition {
    static let hostKey = "Host"
    static let name = "Reachability"
    static let isMutuallyExclusive = false
    
    let host: NSURL
    
    init(host: NSURL) {
        self.host = host
    }
    
    func dependencyForOperation(operation: Operation) -> NSOperation? {
        return nil
    }
    
    func evaluateForOperation(operation: Operation, completion: OperationCompletionResult -> Void) {
        ReachabilityController.requestReachability(host) { reachable in
            if reachable {
                completion(.Satisfied)
            } else {
                let error = NSError(error: ErrorSpecification(
                    ec: OperationError.ConditionFailed),
                    userInfo: [
                        OperationConditionKey: self.dynamicType.name,
                        self.dynamicType.hostKey: self.host
                    ]
                )
                
                completion(.Failed(error))
            }
        }
    }
}

private class ReachabilityController {
    static var reachabilityRefs = [String: SCNetworkReachability]()
    
    static let reachabilityQueue = dispatch_queue_create("Operations.Reachability", DISPATCH_QUEUE_SERIAL)
    
    static func requestReachability(url: NSURL, completionHandler: (Bool) -> Void) {
        if let host = url.host {
            dispatch_async(reachabilityQueue) {
                var ref = self.reachabilityRefs[host]
                
                if ref == nil {
                    let hostString = host as NSString
                    ref = SCNetworkReachabilityCreateWithName(nil, hostString.UTF8String)
                }
                
                if let ref = ref {
                    self.reachabilityRefs[host] = ref
                    
                    var reachable = false
                    var flags: SCNetworkReachabilityFlags = []
                    if SCNetworkReachabilityGetFlags(ref, &flags) != Bool(0) {
                        /*
                        Note that this is a very basic "is reachable" check.
                        Your app may choose to allow for other considerations,
                        such as whether or not the connection would require
                        VPN, a cellular connection, etc.
                        */
                        reachable = flags.contains(.Reachable)
                    }
                    completionHandler(reachable)
                }
                else {
                    completionHandler(false)
                }
            }
        }
        else {
            completionHandler(false)
        }
    }
}
