
import CoreLocation

public class GetCurrentLocationOperation: Operation, CLLocationManagerDelegate {
    
    private let accuracy: CLLocationAccuracy
    private var manager: CLLocationManager?
    private let handler: CLLocation -> Void
    
    public init(accuracy: CLLocationAccuracy, locationHandler: CLLocation -> Void) {
        self.accuracy = accuracy
        self.handler = locationHandler
        
        super.init()
        
        addCondition(LocationCondition(usage: .WhenInUse))
        addCondition(MutuallyExclusive<CLLocationManager>())
    }
    
    public override func execute() {
        executeOnMainThread {
            let manager = CLLocationManager()
            manager.desiredAccuracy = self.accuracy
            manager.delegate = self
            manager.startUpdatingLocation()
            
            self.manager = manager
        }
    }
    
    public override func cancel() {
        executeOnMainThread {
            self.stopLocationUpdates()
            super.cancel()
        }
    }
    
    private func stopLocationUpdates() {
        manager?.stopUpdatingLocation()
        manager = nil
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last where location.horizontalAccuracy <= accuracy else {
            return
        }
        
        stopLocationUpdates()
        handler(location)
        finish()
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        stopLocationUpdates()
        finishWithError(error)
    }
}
