
public struct NetworkActivityObserver: OperationObserver {
    
    public init() { }
    
    public func operationDidStart(operation: Operation) {
        executeOnMainThread {
            NetworkIndicatorManager.sharedManager.networkActivityDidStart()
        }
    }
    
    public func operationDidFinish(operation: Operation, errors: [NSError]) {
        executeOnMainThread {
            NetworkIndicatorManager.sharedManager.networkActivityDidEnd()
        }
    }
    
    public func operation(operation: Operation, didProduceOperation newOperation: NSOperation) { }
}

private class NetworkIndicatorManager {
    static let sharedManager = NetworkIndicatorManager()
    
    private var activiyCount = 0
    private var visibilityTimer: Timer?
    
    func networkActivityDidStart() {
        assert(NSThread.isMainThread(), "Only on main thread!")
        
        activiyCount += 1
        
        updateNetworkActivityIndicatorVisibility()
    }
    
    func networkActivityDidEnd() {
        assert(NSThread.isMainThread(), "Only on main thread!")
        
        activiyCount -= 1
        
        updateNetworkActivityIndicatorVisibility()
    }
    
    private func updateNetworkActivityIndicatorVisibility() {
        if activiyCount > 0 {
            showIndicator()
        } else {
            visibilityTimer = Timer(interval: 1.0) {
                self.hideIndicator()
            }
        }
    }
    
    private func showIndicator() {
        visibilityTimer?.cancel()
        visibilityTimer = nil
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    private func hideIndicator() {
        visibilityTimer?.cancel()
        visibilityTimer = nil
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}

private class Timer {
    var isCancelled = false
    
    init(interval: NSTimeInterval, handler: dispatch_block_t) {
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC)))
        
        dispatch_after(when, dispatch_get_main_queue()) { [weak self] in
            if self?.isCancelled == false {
                handler()
            }
        }
    }
    
    func cancel() {
        isCancelled = true
    }
}
