
public protocol Endpoint {
    var apiBase: String { get }
    
    func URL() -> NSURL
    func URL(path path: String?) -> NSURL
    func URL(params params: [String:String]?) -> NSURL
}

extension Endpoint {
    public var apiBase: String {
        return "https://httpbin.org"
    }
    
    public func URL() -> NSURL {
        return NSURL(string: apiBase)!
    }
    
    public func URL(params params: [String:String]?) -> NSURL {
        return URL()
    }
    
    public func URL(path path: String?) -> NSURL {
        return URL()
    }
}

public struct NullEndpoint: Endpoint { }

public enum EndpointType {
    case Simple
    case Composed
}