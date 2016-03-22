
import UIKit

private let RemoteNotificationQueue = OperationQueue()
private let RemoteNotificationName = "RemoteNotificationPermissionNotification"

public enum RemoteRegistrationResult {
    case Token(NSData)
    case Error(NSError)
}

public struct RemoteNotificationCondition: OperationCondition {
    public static let name                = "RemoteNotification"
    public static let isMutuallyExclusive = false
    
    static func didReceiveNotificationToken(token: NSData) {
        NSNotificationCenter.defaultCenter().postNotificationName(RemoteNotificationName, object: nil, userInfo: [
            "token": token
            ]
        )
    }
    
    static func didFailToRegister(error: NSError) {
        NSNotificationCenter.defaultCenter().postNotificationName(RemoteNotificationName, object: nil, userInfo: [
            "error": error
            ]
        )
    }
    
    let application: UIApplication
    
    public init(application: UIApplication) {
        self.application = application
    }
    
    public func dependencyForOperation(operation: Operation) -> NSOperation? {
        return RemoteNotificationPermissionRequestOperation(application: application, handler: { _ in })
    }
    
    public func evaluateForOperation(operation: Operation, completion: OperationCompletionResult -> Void) {
        RemoteNotificationQueue.addOperation(RemoteNotificationPermissionRequestOperation(application: application) { result in
            switch result {
            case .Token(_):
                completion(.Satisfied)
                
            case .Error(let underlyingError):
                let error = NSError(error: ErrorSpecification(ec: OperationError.ConditionFailed), userInfo: [
                    OperationConditionKey: self.dynamicType.name,
                    NSUnderlyingErrorKey: underlyingError
                    ])
                
                completion(.Failed(error))
            }
            }
        )
    }
}

private class RemoteNotificationPermissionRequestOperation: Operation {
    let application: UIApplication
    private let handler: RemoteRegistrationResult -> Void
    
    private init(application: UIApplication, handler: RemoteRegistrationResult -> Void) {
        self.application = application
        self.handler = handler
        
        super.init()
        
        addCondition(MutuallyExclusive<RemoteNotificationPermissionRequestOperation>())
    }
    
    private override func execute() {
        executeOnMainThread {
            let notificationCenter = NSNotificationCenter.defaultCenter()
            
            notificationCenter.addObserver(
                self,
                selector: #selector(
                    RemoteNotificationPermissionRequestOperation.didReceiveResponse(_:)
                ),
                name: RemoteNotificationName,
                object: nil
            )
            
            self.application.registerForRemoteNotifications()
        }
    }
    
    @objc func didReceiveResponse(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        let userInfo = notification.userInfo
        
        if let token = userInfo?["token"] as? NSData {
            handler(.Token(token))
        } else if let error = userInfo?["error"] as? NSError {
            handler(.Error(error))
        } else {
            fatalError("Received a notification without a token and without an error.")
        }
        
        finish()
    }
}