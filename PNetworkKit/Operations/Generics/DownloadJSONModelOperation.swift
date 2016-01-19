
private let urlSession = NSURLSession(
    configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration()
)

public enum HTTPMethod: String {
    case GET  = "GET"
    case POST = "POST"
}

public class DownloadJSONOperation: GroupOperation {
    // MARK: - Private Properties
    private let __error: (NSError -> Void)?
    private let __completion: ([String:AnyObject]? -> Void)?
    
    private var composedEndpointURL: NSURL {
        let (endpoint, params) = self.composedEndpoint
        return endpoint.URL(params: params)
    }
    
    private var simpleEndpointURL: NSURL {
        return simpleEndpoint.URL()
    }
    
    
    // MARK: - Public Properties/Overridables
    public let cacheFile: NSURL
    
    public var endpointType: EndpointType {
        return .Simple
    }
    
    public var simpleEndpoint: Endpoint {
        return NullEndpoint()
    }
    
    public var composedEndpoint: (Endpoint, [String:String]) {
        return (NullEndpoint(), ["":""])
    }
    
    public var method: HTTPMethod {
        return .GET
    }
    
    public var headerParams: [String:String]? {
        return nil
    }
    
    public var requestBody: [String:AnyObject]? {
        return nil
    }
    
    
    // MARK: - Public Initialisers
    
    public init?(
        cacheFile: NSURL,
        url: NSURL? = nil
        ) {
            self.cacheFile = cacheFile
            __error        = nil
            __completion   = nil
            
            super.init(operations: [])
            name = "DownloadJSONOperation<\(self.dynamicType)>"
            
            guard let request = getRequestWithDefaultURL(url) else {
                return
            }
            
            let networkTaskOperation = getDownloadTaskOperationWithRequest(request)
            
            addOperation(networkTaskOperation)
            addOperation(NSOperation())
    }
    
    public init?(
        url: NSURL? = nil,
        completion: ([String:AnyObject]? -> Void)?,
        error: (NSError -> Void)?
        ) {
            cacheFile    = NSURL()
            __error      = error
            __completion = completion
            
            super.init(operations: [])
            name = "DownloadJSONOperation<\(self.dynamicType)>"
            
            guard let request = getRequestWithDefaultURL(url) else {
                return
            }
            
            let networkTaskOperation = getDataTaskOperationWithRequest(request)
            
            addOperation(networkTaskOperation)
            addOperation(NSOperation())
    }
}


// MARK: - Private Methods
extension DownloadJSONOperation {
    private func getRequestWithDefaultURL(defaultURL: NSURL?) -> NSURLRequest? {
        guard let url = getURL(defaultURL: defaultURL) else {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        request.HTTPBody = getRequestBodyData()
        
        if let headerParams = headerParams {
            for param in headerParams {
                request.setValue(param.1, forHTTPHeaderField: param.0)
            }
        }
        
        return request
    }
    
    private func getDataTaskOperationWithRequest(
        request: NSURLRequest
        ) -> URLSessionTaskOperation {
            let task = urlSession.dataTaskWithRequest(request) {
                data, response, error in
                self.dataRequestFinishedWithData(
                    data,
                    response: response,
                    error: error
                )
            }
            
            let networkTaskOperation = URLSessionTaskOperation(task: task)
            
            return prepareNetworkTaskOperation(networkTaskOperation)
    }
    
    private func getDownloadTaskOperationWithRequest(
        request: NSURLRequest
        ) -> URLSessionTaskOperation {
            let task = urlSession.downloadTaskWithRequest(request) {
                url, response, error in
                self.downloadRequestFinishedWithUrl(
                    url,
                    response: response,
                    error: error
                )
            }
            
            let networkTaskOperation = URLSessionTaskOperation(task: task)
            
            return prepareNetworkTaskOperation(networkTaskOperation)
    }
    
    private func dataRequestFinishedWithData(
        data: NSData?,
        response: NSURLResponse?,
        error: NSError?
        ) {
            if let error = error {
                __error?(error)
                finishWithError(error)
                
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data,
                    options: .MutableContainers
                    ) as? [String:AnyObject]
                __completion?(json)
            } catch let error as NSError {
                __error?(error)
                finishWithError(error)
                
                return
            }
    }
    
    private func downloadRequestFinishedWithUrl(
        url: NSURL?,
        response: NSURLResponse?,
        error: NSError?
        ) {
            if let localUrl = url {
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(cacheFile)
                } catch { }
                
                do {
                    try NSFileManager.defaultManager().moveItemAtURL(
                        localUrl,
                        toURL: cacheFile
                    )
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
    
    private func getURL(defaultURL defaultURL: NSURL?) -> NSURL? {
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
        
        return url
    }
    
    private func getRequestBodyData() -> NSData? {
        if let requestBody = requestBody {
            do {
                let requestData = try NSJSONSerialization.dataWithJSONObject(
                    requestBody,
                    options: .PrettyPrinted
                )
                return requestData
            } catch {
                debugPrint("Data \(requestBody) could not be serialized.")
            }
        }
        
        return nil
    }
    
    private func prepareNetworkTaskOperation(
        networkTaskOperation: URLSessionTaskOperation
        ) -> URLSessionTaskOperation {
            if let url = networkTaskOperation.task.originalRequest?.URL {
                let reachabilityCondition = ReachabilityCondition(host: url)
                networkTaskOperation.addCondition(reachabilityCondition)
            }
            
            let networkObserver = NetworkActivityObserver()
            networkTaskOperation.addObserver(networkObserver)
            
            return networkTaskOperation
    }
}