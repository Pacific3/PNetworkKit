
public typealias GeocodingCompletion = [CLPlacemark] -> Void

private class _GeocodeOperation: Operation {
    private let geoCoder = CLGeocoder()
    private var searchTerm: String
    private var completion: GeocodingCompletion
    
    init(searchTerm: String, completion: GeocodingCompletion) {
        self.searchTerm = searchTerm
        self.completion = completion
    }
    
    override func execute() {
        geoCoder.geocodeAddressString(searchTerm) { placemarks, error in
            guard let placemarks = placemarks where error != nil else {
                self.finishWithError(error)
                return
            }
            
            self.completion(placemarks)
            self.finish()
        }
    }
}

public class GeocodeOpration: GroupOperation {
    private let geocodeOperation: _GeocodeOperation
    
    public init(searchTerm: String, completion: GeocodingCompletion) {
        geocodeOperation = _GeocodeOperation(searchTerm: searchTerm, completion: completion)
        geocodeOperation.addObserver(NetworkActivityObserver())
        
        super.init(operations: [geocodeOperation])
        name = "Geocode Operation"
    }
}