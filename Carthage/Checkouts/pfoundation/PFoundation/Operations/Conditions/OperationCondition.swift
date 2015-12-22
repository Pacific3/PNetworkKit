
public let OperationConditionKey = "OperationCondition"

public protocol OperationCondition {
    static var name: String { get }
    static var isMutuallyExclusive: Bool { get }
    
    func dependencyForOperation(operation: Operation) -> NSOperation?
    func evaluateForOperation(operation: Operation, completion: OperationCompletionResult -> Void)
}

public enum OperationCompletionResult: Equatable {
    case Satisfied
    case Failed(NSError)
    
    var error: NSError? {
        if case .Failed(let error) = self {
            return error
        }
        
        return nil
    }
}

public func ==(lhs: OperationCompletionResult, rhs: OperationCompletionResult) -> Bool {
    switch (lhs, rhs) {
    case (.Satisfied, .Satisfied):
        return true
    case (.Failed(let lError), .Failed(let rError)) where lError == rError:
        return true
    default:
        return false
    }
}

struct OperationConditionEvaluator {
    static func evaluate(conditions: [OperationCondition], operation: Operation, completion: [NSError] -> Void) {
        let conditionGroup = dispatch_group_create()
        
        var results = [OperationCompletionResult?](count: conditions.count, repeatedValue: nil)
        
        for (index, condition) in conditions.enumerate() {
            dispatch_group_enter(conditionGroup)
            condition.evaluateForOperation(operation) { result in
                results[index] = result
                dispatch_group_leave(conditionGroup)
            }
        }
        
        dispatch_group_notify(conditionGroup, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            var failures = results.flatMap { $0?.error }
            
            if operation.cancelled {
                failures.append(NSError(error: ErrorSpecification(ec: OperationError.ConditionFailed)))
            }
            
            completion(failures)
        }
    }
}
