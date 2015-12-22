
infix operator >>>= {}
public func >>>= <A, B> (optional: A?, f: A -> B?) -> B? {
    return flatten(optional.map(f))
}

infix operator <*> { associativity left precedence 150 }
public func <*><A, B>(l: (A -> B)?, r: A?) -> B? {
    if let
        l1 = l,
        r1 = r {
            return l1(r1)
    }
    
    return nil
}
