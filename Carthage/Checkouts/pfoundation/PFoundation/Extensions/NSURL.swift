
extension NSURL {
    public func URLWithParams(params: [String:String])-> NSURL? {
        return NSURL(string: "\(self)?\(params.toURLEncodedString())")
    }
}
