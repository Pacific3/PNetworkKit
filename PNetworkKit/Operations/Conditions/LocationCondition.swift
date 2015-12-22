
import CoreLocation

struct LocationCondition: OperationCondition {
    
    enum Usage {
        case WhenInUse
        case Always
    }
    
    static let name = "Location"
    static let locationServicesEnabledKey = "CLLocationServicesEnabled"
    static let authorizationStatusKey = "CLAuthorizationSTatus"
    static let isMutuallyExclusive = false
    
    let usage: Usage
    
    init(usage: Usage) {
        self.usage = usage
    }
    
    func dependencyForOperation(operation: Operation) -> NSOperation? {
        return LocationPermissionOperation(usage: usage)
    }
    
    func evaluateForOperation(operation: Operation, completion: OperationCompletionResult -> Void) {
        let enabled = CLLocationManager.locationServicesEnabled()
        let actual = CLLocationManager.authorizationStatus()
        
        var error: NSError?
        
        switch (enabled, usage, actual) {
        case (true, _, .AuthorizedAlways):
            break
            
        case (true, .WhenInUse, .AuthorizedWhenInUse):
            break
            
        default:
            error = NSError(error: ErrorSpecification(ec: OperationError.ConditionFailed), userInfo: [
                OperationConditionKey: self.dynamicType.name,
                self.dynamicType.locationServicesEnabledKey: enabled,
                self.dynamicType.authorizationStatusKey: Int(actual.rawValue)
                ])
        }
        
        if let error = error {
            completion(.Failed(error))
        } else {
            completion(.Satisfied)
        }
    }
}

private class LocationPermissionOperation: Operation {
    let usage: LocationCondition.Usage
    var manager: CLLocationManager?
    
    init(usage: LocationCondition.Usage) {
        self.usage = usage
        
        super.init()
        
        addCondition(AlertPresentation())
    }
    
    private override func execute() {
        switch (CLLocationManager.authorizationStatus(), usage) {
        case (.NotDetermined, _), (.AuthorizedWhenInUse, .Always):
            executeOnMainThread {
                self.requestPermission()
            }
            
        default:
            finish()
        }
        
    }
    
    private func requestPermission() {
        manager = CLLocationManager()
        manager?.delegate = self
        let key: String
        switch usage {
        case .WhenInUse:
            key = "NSLocationWhenInUseUsageDescription"
            manager?.requestWhenInUseAuthorization()
            
        case .Always:
            key = "NSlocationAlwaysUsageDescription"
            manager?.requestAlwaysAuthorization()
        }
        
        assert(NSBundle.mainBundle().objectForInfoDictionaryKey(key) != nil, "Requesting location permition requires the \(key) in the Info.plist file!")
    }
}

extension LocationPermissionOperation: CLLocationManagerDelegate {
    @objc func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if manager == self.manager && executing && status != .NotDetermined {
            finish()
        }
    }
}