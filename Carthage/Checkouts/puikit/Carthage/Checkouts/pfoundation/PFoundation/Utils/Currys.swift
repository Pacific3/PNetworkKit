
public func curry<A, B, R> (f: (A, B) -> R) -> A -> B -> R {
    return { a in { b in f(a, b) } }
}

public func curry<A, B, C, R> (f: (A, B, C) -> R) -> A -> B -> C -> R {
    return { a in { b in { c in f(a, b, c) } } }
}

public func curry<A, B, C, D, R> (f: (A, B, C, D) -> R) -> A -> B -> C -> D -> R {
    return { a in { b in { c in { d in f(a, b, c, d) } } } }
}

public func curry<A, B, C, D, E, R> (f: (A, B, C, D, E) -> R) -> A -> B -> C -> D -> E -> R {
    return { a in { b in { c in { d in { e in f(a, b, c, d, e) } } } } }
}

public func curry<A, B, C, D, E, F, R> (fx: (A, B, C, D, E, F) -> R) -> A -> B -> C -> D -> E -> F -> R {
    return { a in { b in { c in { d in { e in { f in fx(a, b, c, d, e, f) } } } } } }
}

public func curry<A, B, C, D, E, F, G, R>(fx: (A, B, C, D, E, F, G) -> R) -> A -> B -> C -> D -> E -> F -> G -> R {
    return { a in { b in { c in { d in { e in { f in { g in fx(a, b, c, d, e, f, g) } } } } } } }
}
