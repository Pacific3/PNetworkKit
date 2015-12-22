
internal let OperationErrorDomain = "net.Pacific3.Foundation.OperationErrorDomain"

public enum OperationError: Int, ErrorConvertible {
    case ConditionFailed = 100
    case ExecutionFailed = 101
    
    public var code: Int {
        return self.rawValue
    }
    
    public var errorDescription: String {
        return self.description
    }
    
    public var domain: String {
        return OperationErrorDomain
    }
}

extension OperationError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ConditionFailed: return "Operation condition failed."
        case .ExecutionFailed: return "Operation execution failed."
        }
    }
}

public func ==(lhs: Int, rhs: OperationError) -> Bool {
    return lhs == rhs.rawValue
}

public func ==(lhs: OperationError, rhs: Int) -> Bool {
    return lhs.rawValue == rhs
}