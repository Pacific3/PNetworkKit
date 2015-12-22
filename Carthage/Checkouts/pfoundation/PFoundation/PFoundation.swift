
public var DocumentsDirectory: NSString? {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first
}

public func executeOnMainThread(handler: (Void -> Void)?) {
    if let block = handler {
        if NSThread.isMainThread() {
            block()
        } else {
            dispatch_sync(dispatch_get_main_queue(), block)
        }
    }
}

public func uniq<S:SequenceType, E: Hashable where E == S.Generator.Element>(source: S) -> [E] {
    var seen: [E:Bool] = [:]
    return source.filter { v -> Bool in
        return seen.updateValue(true, forKey: v) == nil
    }
}

public func executeOnMainThread<A>(x: A?, handler: ((A) -> Void)?) {
    if NSThread.isMainThread() {
        handler <*> x
    } else {
        dispatch_async(dispatch_get_main_queue()) {
            handler <*> x
        }
    }
}

public func executeOnMainThread<A, B>(x: A?, y: B?, block: ((A, B) -> Void)?) {
    if let block = block {
        let mkBlock = curry { a, b in block(a, b) }
        
        if NSThread.isMainThread() {
            mkBlock <*> x <*> y
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                mkBlock <*> x <*> y
            }
        }
    }
}

public func executeAfter(time: NSTimeInterval, handler: Void -> Void) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
    
    dispatch_after(when, dispatch_get_main_queue()) {
        handler()
    }
}

public func executeOnFirstLaunch(handler: (Void -> Void)?) {
    let hasRunOnce = user_defaults_get_bool(kApplicationHasAlreadyRunOnce)
    if let block = handler where !hasRunOnce {
        block()
        user_defaults_set_bool(kApplicationHasAlreadyRunOnce, val: true)
    }
}

public func encode(o: AnyObject) -> String? {
    guard let string = o as? String else {
        return nil
    }
    
    return string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLUserAllowedCharacterSet())
}


// MARK: - Functional stuff

public func flatten<A>(x: A??) -> A? {
    if let y = x { return y }
    return nil
}


// MARK: - Casting

public func toDict(x: AnyObject) -> [String:AnyObject]? {
    return x as? [String:AnyObject]
}


// MARK: - Getting Data From [String:AnyObject]s

public func number(input: [NSObject:AnyObject], key: String) -> NSNumber? {
    return input[key] >>>= { $0 as? NSNumber }
}

public func int(input: [NSObject:AnyObject], key: String) -> Int? {
    return number(input, key: key).map { $0.integerValue }
}

public func float(input: [NSObject:AnyObject], key: String) -> Float? {
    return number(input, key: key).map { $0.floatValue }
}

public func double(input: [NSObject:AnyObject], key: String) -> Double? {
    return number(input, key: key).map { $0.doubleValue }
}

public func string(input: [String:AnyObject], key: String) -> String? {
    return input[key] >>>= { $0 as? String }
}

public func bool(input: [String:AnyObject], key: String) -> Bool? {
    return number(input, key: key).map { $0.boolValue }
}

public func array(input: [String:AnyObject], key: String) -> [AnyObject]? {
    let maybeAny: AnyObject? = input[key]
    return maybeAny >>>= { $0 as? [AnyObject] }
}

public func arrayOf<A>(input: [String:AnyObject], key: String) -> [A]? {
    let maybeAny: AnyObject? = input[key]
    return maybeAny >>>= { $0 as? [A] }
}
