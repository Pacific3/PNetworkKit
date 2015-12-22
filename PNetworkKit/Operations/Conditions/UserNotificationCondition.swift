

import UIKit

public struct UserNotificationCondition: OperationCondition {
    public enum Behavior {
        case Merge
        case Replace
    }
    
    static let currentSettings            = "CurrentUserNotificationSettings"
    static let desiredSettings            = "DesiredUserNotificationSettings"
    public static let name                = "UserNotification"
    public static let isMutuallyExclusive = false
    
    let settings: UIUserNotificationSettings
    let application: UIApplication
    let behavior: Behavior
    
    public init(settings: UIUserNotificationSettings, application: UIApplication, behavior: Behavior = .Merge) {
        self.settings = settings
        self.application = application
        self.behavior = behavior
    }
    
    public func dependencyForOperation(operation: Operation) -> NSOperation? {
        return UserNotificationPermissionRequestOperation(settings: settings, application: application, behavior: behavior)
    }
    
    public func evaluateForOperation(operation: Operation, completion: OperationCompletionResult -> Void) {
        let result: OperationCompletionResult
        let current = application.currentUserNotificationSettings()
        
        switch (current, settings) {
        case (let current?, let settings) where current.contains(settings):
            result = .Satisfied
            
        default:
            let error = NSError(error: ErrorSpecification(ec: OperationError.ConditionFailed), userInfo: [
                OperationConditionKey: self.dynamicType.name,
                self.dynamicType.currentSettings: current ?? NSNull(),
                self.dynamicType.desiredSettings: settings
                ]
            )
            
            result = .Failed(error)
        }
        
        completion(result)
    }
}

private class UserNotificationPermissionRequestOperation: Operation {
    let settings: UIUserNotificationSettings
    let application: UIApplication
    let behavior: UserNotificationCondition.Behavior
    
    init(settings: UIUserNotificationSettings, application: UIApplication, behavior: UserNotificationCondition.Behavior) {
        self.settings = settings
        self.application = application
        self.behavior = behavior
        
        super.init()
        
        addCondition(AlertPresentation())
    }
    
    private override func execute() {
        executeOnMainThread {
            let current = self.application.currentUserNotificationSettings()
            
            let settingsToRegister: UIUserNotificationSettings
            
            switch (current, self.behavior) {
            case (let currentSettings?, .Merge):
                settingsToRegister = currentSettings.settingsByMerging(self.settings)
                
            default:
                settingsToRegister = self.settings
            }
            
            self.application.registerUserNotificationSettings(settingsToRegister)
        }
    }
}
