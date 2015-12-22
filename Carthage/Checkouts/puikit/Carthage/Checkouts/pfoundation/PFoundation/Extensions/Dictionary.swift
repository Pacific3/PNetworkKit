
extension Dictionary {
    public func toURLEncodedString() -> String {
        var pairs = [String]()
        for element in self {
            if let key = encode(element.0 as! AnyObject),
                let value = encode(element.1 as! AnyObject) where (!value.isEmpty && !key.isEmpty) {
                    pairs.append([key, value].joinWithSeparator("="))
            } else {
                continue
            }
        }
        
        guard !pairs.isEmpty else {
            return ""
        }
        
        return pairs.joinWithSeparator("&")
    }
}
