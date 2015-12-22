
public protocol JSONParselable {
    static func withData(data: [String:AnyObject]) -> Self?
}

public extension JSONParselable {
    public static func withData(data: [String:AnyObject]) -> Self? {
        return nil
    }
}

public struct NullParselable: JSONParselable {}