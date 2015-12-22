public class Operation: NSOperation {
    
    //MARK: - KVO
    class func keyPathsForValuesAffectingIsReady() -> Set<NSObject> {
        return ["state"]
    }
    
    class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state"]
    }
    
    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state"]
    }
    
    
    // MARK: - State management
    
    private enum State: Int, Comparable {
        case Initialized
        case Pending
        case EvaluatingConditions
        case Ready
        case Executing
        case Finishing
        case Finished
        
        func canTransitionToState(target: State) -> Bool {
            switch (self, target) {
            case (.Initialized, .Pending):
                return true
            case (.Pending, .EvaluatingConditions):
                return true
            case (.EvaluatingConditions, .Ready):
                return true
            case (.Ready, .Executing):
                return true
            case (.Ready, .Finishing):
                return true
            case (.Executing, .Finishing):
                return true
            case (.Finishing, .Finished):
                return true
            default:
                return false
            }
        }
    }
    private var _state = State.Initialized
    private let stateLock = NSLock()
    
    private var state: State {
        get {
            return stateLock.withCriticalScope {
                _state
            }
        }
        
        set(newState) {
            willChangeValueForKey("state")
            
            stateLock.withCriticalScope {
                guard _state != .Finished else {
                    return
                }
                
                assert(_state.canTransitionToState(newState), "invalid state transition.")
                _state = newState
            }
            
            didChangeValueForKey("state")
        }
    }
    
    
    // MARK: - Operation "readiness"
    
    override public var ready: Bool {
        switch state {
        case .Initialized:
            return cancelled
            
        case .Pending:
            guard !cancelled else {
                return true
            }
            
            if super.ready {
                evaluateConditions()
            }
            
            return false
            
        case .Ready:
            return super.ready || cancelled
            
        default:
            return false
        }
    }
    
    public var userInitiated: Bool {
        get {
            return qualityOfService == .UserInitiated
        }
        
        set {
            assert(state < .Executing, "Can't modify the state after user execution has begun.")
            
            qualityOfService = newValue ? .UserInitiated : .Default
        }
    }
    
    override public var executing: Bool {
        return state == .Executing
    }
    
    override public var finished: Bool {
        return state == .Finished
    }
    
    
    private var _internalErrors = [NSError]()
    func cancelWithError(error: NSError? = nil) {
        if let error = error {
            _internalErrors.append(error)
        }
        
        cancel()
    }
    
    func willEnqueue() {
        _state = .Pending
    }
    
    
    // MARK: - Observers, conditions, dependencies
    
    private(set) var observers = [OperationObserver]()
    public func addObserver(observer: OperationObserver) {
        assert(state < .Executing, "Can't modify observes after execution has begun.")
        
        observers.append(observer)
    }
    
    private(set) var conditions = [OperationCondition]()
    public func addCondition(condition: OperationCondition) {
        assert(state < .EvaluatingConditions, "Can't add conditions once execution has begun.")
        
        conditions.append(condition)
    }
    
    override public func addDependency(operation: NSOperation) {
        assert(state < .Executing, "Dependencies cannot be modified after execution has begun.")
        
        super.addDependency(operation)
    }
    
    func evaluateConditions() {
        assert(state == .Pending && !cancelled, "evaluating conditions out of order!")
        
        state = .EvaluatingConditions
        
        OperationConditionEvaluator.evaluate(conditions, operation: self) { failures in
            self._internalErrors.appendContentsOf(failures)
            self.state = .Ready
        }
        
    }
    
    // MARK: - Execution
    
    override final public func start() {
        super.start()
        
        if cancelled {
            finish()
        }
    }
    
    override final public func main() {
        assert(state == .Ready, "This operation must be performed by an operation queue.")
        
        if _internalErrors.isEmpty && !cancelled {
            state = .Executing
            
            for observer in observers {
                observer.operationDidStart(self)
            }
            
            execute()
        } else {
            finish()
        }
    }
    
    public func execute() {
        print("\(self.dynamicType) must override `execute()`.")
        finish()
    }
    
    public final func produceOperation(operation: NSOperation) {
        for observer in observers {
            observer.operation(self, didProduceOperation: operation)
        }
    }
    
    
    // MARK: - Finishing
    
    public final func finishWithError(error: NSError?) {
        if let error = error {
            finish([error])
        } else {
            finish()
        }
    }
    
    private var hasFinished = false
    public func finish(errors: [NSError] = []) {
        if !hasFinished {
            hasFinished = true
            state = .Finishing
            
            let combinedErrors = _internalErrors + errors
            finished(combinedErrors)
            
            for observer in observers {
                observer.operationDidFinish(self, errors: combinedErrors)
            }
            
            state = .Finished
        }
    }
    
    func finished(errors: [NSError]) {
        // Optional
    }
    
    override final public func waitUntilFinished() {
        fatalError("Nope!")
    }
}

// MARK: - Operators
private func <(lhs: Operation.State, rhs: Operation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

private func ==(lhs: Operation.State, rhs: Operation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
