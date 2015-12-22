
extension NSError {
    convenience public init(error: ErrorSpecification<Int, String, String>) {
        self.init(domain: error.domain, code: error.code, userInfo: [NSLocalizedDescriptionKey:error.errorDescription])
    }
    
    convenience public init(error: ErrorSpecification<Int, String, String>, userInfo: [NSString:AnyObject]) {
        self.init(domain: error.domain, code: error.code, userInfo: userInfo)
    }
}


