
public class ParseJSONOperation<T: JSONParselable>: Operation {
    internal var parsedObjects: [T]?
    let cacheFile: NSURL
    
    private var _realmConfiguration: Realm.Configuration?
    public var realmConfiguration: Realm.Configuration? {
        get {
            if let rc = _realmConfiguration { return rc } else {
                _realmConfiguration = Realm.Configuration()
                
                return _realmConfiguration
            }
        }
        
        set {
            _realmConfiguration = newValue
        }
    }
    
    public init(cacheFile c: NSURL, realmConfiguration rc: Realm.Configuration? = nil) {
        cacheFile = c
        
        super.init()
        
        realmConfiguration = rc
        
        name = "ParseJSONOperation<\(T.self)>"
    }
    
    override public func execute() {
        guard let jsonData = NSData(contentsOfURL: cacheFile) else {
            finish()
            return
        }
        
        guard let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) else {
            finish()
            return
        }
        
        var s = String(jsonString)
        if s.characters.first != "[" {
            s = "[" + s + "]"
        }
        
        let newJsonData = (s as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(newJsonData, options: []) as? [[String:AnyObject]]
            if let json = json {
                parse(json)
            } else {
                finish()
            }
        } catch let error as NSError {
            finishWithError(error)
        }
    }
    
    public func parse(json: [[String:AnyObject]]) {
        parsedObjects = json.flatMap{ T.withData($0) }
        process()
        finish()
    }
    
    public func process() {
        fatalError("Subclasses must override this method to process parsedObjects.")
    }
}
