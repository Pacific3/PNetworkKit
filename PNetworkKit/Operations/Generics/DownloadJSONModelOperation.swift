
public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

public class DownloadJSONOperation: GroupOperation {
    private var composedEndpointURL: NSURL {
        let (endpoint, params) = self.composedEndpoint
        return endpoint.URL(params: params)
    }
    
    private var simpleEndpointURL: NSURL {
        return simpleEndpoint.URL()
    }
    
    let cacheFile: NSURL
    
    var endpointType: EndpointType {
        return .Simple
    }
    
    var simpleEndpoint: Endpoint {
        return NullEndpoint()
    }
    
    var composedEndpoint: (Endpoint, [String:String]) {
        return (NullEndpoint(), ["":""])
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var headerParams: [String:String]? {
        return nil
    }
    
    var requestBody: [String:AnyObject]? {
        return nil
    }
    
    public init(cacheFile: NSURL, url defaultURL: NSURL? = nil) {
        self.cacheFile = cacheFile
        super.init(operations: [])
        name = "DownloadJSONOperation<\(self.dynamicType)>"
        
        var url: NSURL?
        
        if let defaultURL = defaultURL {
            url = defaultURL
        } else {
            switch endpointType {
            case .Simple:
                url = simpleEndpointURL
                
            case .Composed:
                url = composedEndpointURL
            }
        }
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = method.rawValue
        
        if let requestBody = requestBody {
            do {
                let requestData = try NSJSONSerialization.dataWithJSONObject(requestBody, options: .PrettyPrinted)
                request.HTTPBody = requestData
            } catch {
                debugPrint("The request data \(requestBody) could not be serialized.")
            }
        }
        
        if let headerParams = headerParams {
            for param in headerParams {
                request.setValue(param.1, forHTTPHeaderField: param.0)
            }
        }
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
        let task = session.downloadTaskWithRequest(request) { url, response, error in
            self.dataRequestFinishedWithUrl(url, response: response, error: error)
        }
        
        let networkTaskOperation = URLSessionTaskOperation(task: task)
        
        let reachabilityCondition = ReachabilityCondition(host: url!)
        networkTaskOperation.addCondition(reachabilityCondition)
        
        let networkObserver = NetworkActivityObserver()
        networkTaskOperation.addObserver(networkObserver)
        
        addOperation(networkTaskOperation)
        addOperation(NSOperation())
    }
    
    private func dataRequestFinishedWithUrl(url: NSURL?, response: NSURLResponse?, error: NSError?) {
        if let localUrl = url {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(cacheFile)
            } catch { }
            
            do {
                try NSFileManager.defaultManager().moveItemAtURL(localUrl, toURL: cacheFile)
            } catch let error as NSError {
                print("error moving file!: \(error)")
                aggregateError(error)
            }
        } else if let error = error {
            print("error downloading data!: \(error)")
            aggregateError(error)
        } else {
            
        }
    }
}
