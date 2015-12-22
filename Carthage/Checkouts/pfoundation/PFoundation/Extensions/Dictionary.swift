
extension Dictionary {
    public init<Sequence: SequenceType where Sequence.Generator.Element == Value>(sequence: Sequence, @noescape keyMapper: Value -> Key?) {
        self.init()
        
        for item in sequence {
            if let key = keyMapper(item) {
                self[key] = item
            }
        }
    }
    
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
