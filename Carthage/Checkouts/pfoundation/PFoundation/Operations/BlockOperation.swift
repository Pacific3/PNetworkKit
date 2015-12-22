
public typealias BlockOperation = (Void -> Void) -> Void

/**
 `RBBlockOperation` is a subclass of `Operation` that executes an arbitrary
 `dispatch_block_t` on the main thread.
 */
class RBBlockOperation: Operation {
    private let block: BlockOperation?
    
    init(block: BlockOperation? = nil) {
        self.block = block
        super.init()
    }
    
    convenience init(mainQueueBlock: dispatch_block_t) {
        self.init(block: { continuation in
            dispatch_async(dispatch_get_main_queue()) {
                mainQueueBlock()
                continuation()
            }
        })
    }
    
    override func execute() {
        guard let block = block else {
            return
        }
        
        block {
            self.finish()
        }
    }
}
