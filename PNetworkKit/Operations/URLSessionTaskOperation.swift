
private var URLSessionTaskOperationContext = 0

public class URLSessionTaskOperation: Operation {
    
    public let task: NSURLSessionTask
    
    private var observerRemoved = false
    private var stateLock = NSLock()
    
    public init(task: NSURLSessionTask) {
        assert(task.state == .Suspended, "Task must be suspended.")
        self.task = task
        
        super.init()
        
        addObserver(
            BlockOperationObserver(
                cancelHandler: { _ in
                    task.cancel()
                }
            )
        )
    }
    
    override public func execute() {
        assert(task.state == .Suspended, "Task was resumed by something other than \(self).")
        
        task.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions(), context: &URLSessionTaskOperationContext)
        
        task.resume()
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &URLSessionTaskOperationContext else { return }
        
        stateLock.withCriticalScope {
            if object === task && keyPath == "state" && !observerRemoved {
                
                switch task.state {
                case .Completed:
                    finish()
                    fallthrough
                    
                case .Canceling, .Completed:
                    observerRemoved = true
                    task.removeObserver(self, forKeyPath: "state")
                    
                default:
                    return
                }
            }
        }
    }
}
