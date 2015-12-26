
public typealias ReverseGeocodingCompletion = CLPlacemark -> Void

private class _ReverseGeocodeOperation: Operation {
    private let geoCoder = CLGeocoder()
    private var completion: ReverseGeocodingCompletion
    private var locationToGeocode: CLLocation
    
    init(location: CLLocation, completion: ReverseGeocodingCompletion) {
        locationToGeocode = location
        self.completion = completion
    }
    
    override func execute() {
        geoCoder.reverseGeocodeLocation(locationToGeocode) { placemarks, error in
            guard let placemark = placemarks?.first else {
                self.finishWithError(NSError(error: ErrorSpecification(ec: OperationError.ExecutionFailed)))
                return
            }
            
            self.completion(placemark)
            self.finish()
        }
    }
}

public class ReverseGeocodeOperation: GroupOperation {
    private let geocodeOperation: _ReverseGeocodeOperation
    
    public init(location: CLLocation, completion: ReverseGeocodingCompletion) {
        geocodeOperation = _ReverseGeocodeOperation(location: location, completion: completion)
        geocodeOperation.addObserver(NetworkActivityObserver())
        
        super.init(operations: [geocodeOperation])
        name = "Reverse Geocode Operation"
    }
}