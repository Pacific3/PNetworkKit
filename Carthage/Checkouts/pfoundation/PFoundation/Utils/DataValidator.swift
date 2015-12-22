
public typealias ValidCompletion = (Bool -> Void)

public protocol DataValidatable {
    var dataValidator: DataValidator? { get set }
    var dependency: DataValidatable? { get set }
    var dependent: DataValidatable? { get set }
    var hasValidData: Bool { get }
    var validationHandler: ValidCompletion? { get set }
    var feed: AnyObject { get }
    
    func refresh()
}

public extension DataValidatable {
    var hasValidData: Bool {
        guard let validator = dataValidator else {
            return false
        }
        
        guard let dependency = dependency else {
            return validator.validate(feed)
        }
        
        return dependency.hasValidData && validator.validate(feed)
    }
}

public protocol DataValidator {
    func validate(feed: AnyObject) -> Bool
}

public enum DefaultValidator: DataValidator {
    case Positive
    case Negative
    
    public func validate(feed: AnyObject) -> Bool {
        return self == .Positive ? true : false
    }
}

public enum Match: String, DataValidator {
    case Email             = "^[_]*([a-z0-9]+(\\.|_*)?)+@([a-z][a-z0-9-]+(\\.|-*\\.))+[a-z]{2,6}$"
    case SixSymbolPassword = "^.{6,}$"
    case Domain            = "^([a-z][a-z0-9-]+(\\.|-*\\.))+[a-z]{2,6}$"
    case Name              = "^[\\w.']{2,}(\\s[\\w.']{2,})+$"
    case PositiveInteger   = "^\\d+$"
    case NegativeInteger   = "^-\\d+$"
    case Integer           = "^-?\\d+$"
    case PhoneNumber       = "^\\+?[\\d\\s]{3,}$"
    case PoneWithCode      = "^\\+?[\\d\\s]+\\(?[\\d\\s]{10,}$"
    case Year              = "^(19|20)\\d{2}$"
    
    public func validate(feed: AnyObject) -> Bool {
        guard let feed = feed as? String,
            let _ = feed.rangeOfString(self.rawValue, options: .RegularExpressionSearch) else {
                return false
        }
        
        return true
    }
}

public enum Equal: DataValidator {
    case ToString(String)
    case ToInt(Int)
    case ToFloat(Float)
    
    public func validate(feed: AnyObject) -> Bool {
        switch self {
        case .ToString(let x):
            guard let feed = feed as? String else {
                return false
            }
            
            return feed == x
            
        case .ToInt(let i):
            guard let feed = feed as? Int else {
                return false
            }
            
            return feed == i
            
        case .ToFloat(let f):
            guard let feed = feed as? Float else {
                return false
            }
            
            return feed == f
        }
    }
}
