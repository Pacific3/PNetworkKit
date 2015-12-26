
public protocol HexColorConvertible: Hashable {
    func hexColor() -> String
}

extension HexColorConvertible {
    public var hashValue: Int {
        return hexColor().hashValue
    }
}

public func ==<C: HexColorConvertible>(lhs: C, rhs: C) -> Bool {
    return lhs.hashValue == rhs.hashValue
}