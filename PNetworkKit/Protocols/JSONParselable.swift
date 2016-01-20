
public protocol JSONParselable {
    static func withData(data: [String:AnyObject]) -> Self?
}

public struct NullParselable: JSONParselable {
    public static func withData(data: [String : AnyObject]) -> NullParselable? {
        return nil
    }
}