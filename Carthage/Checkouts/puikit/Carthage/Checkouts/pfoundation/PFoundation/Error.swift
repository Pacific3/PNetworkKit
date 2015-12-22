public let ErrorDomain = "net.Pacific3.ErrorDomainSpecification"

public protocol ErrorConvertible {
    typealias Code
    typealias Description
    typealias Domain
    
    var code: Code { get }
    var errorDescription: Description { get }
    var domain: Domain { get }
}

public enum Error: ErrorConvertible {
    case Error(Int, String)
    case None
    
    public var code: Int {
        return getCode()
    }
    
    public var errorDescription: String {
        return getErrorDescription()
    }
    
    public var domain: String {
        return ErrorDomain
    }
    
    func getCode() -> Int {
        switch self {
        case let .Error(c, _):
            return c
            
        case .None:
            return -1001
        }
    }
    
    func getErrorDescription() -> String {
        switch self {
        case let .Error(_, d):
            return d
            
        case .None:
            return "Malformed error."
        }
    }
}

public struct ErrorSpecification<CodeType, DescriptionType, DomainType>: ErrorConvertible {
    var _code: CodeType
    var _desc: DescriptionType
    var _domain: DomainType
    
    public var code: CodeType {
        return _code
    }
    
    public var errorDescription: DescriptionType {
        return _desc
    }
    
    public var domain: DomainType {
        return _domain
    }
    
    public init<E: ErrorConvertible where E.Code == CodeType, E.Description == DescriptionType, E.Domain == DomainType>(ec: E) {
        _code = ec.code
        _desc = ec.errorDescription
        _domain = ec.domain
    }
}
