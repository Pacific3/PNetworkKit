
private var URLSessionTaskOperationContext = 0

public class URLSessionTaskOperation: Operation {
    
    let task: NSURLSessionTask
    
    public init(task: NSURLSessionTask) {
        assert(task.state == .Suspended, "Task must be suspended.")
        self.task = task
        super.init()
    }
    
    override public func execute() {
        assert(task.state == .Suspended, "Task was resumed by something other than \(self).")
        
        task.addObserver(self, forKeyPath: "state", options: [], context: &URLSessionTaskOperationContext)
        
        task.resume()
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &URLSessionTaskOperationContext else { return }
        
        if object === task && keyPath == "state" && task.state == .Completed {
            task.removeObserver(self, forKeyPath: "state")
            finish()
        }
    }
    
    override public func cancel() {
        //FIXME: Crash if scroll before image is loaded
        task.cancel()
        super.cancel()
    }
}
