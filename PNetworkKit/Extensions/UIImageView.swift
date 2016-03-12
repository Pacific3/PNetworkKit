
public let kPNKDidFinishSettingImageFromURLToImageView = "kPNKDidFinishSettingImageFromURLToImageView"

private func imageCacheKeyFromURLRequest(request: NSURLRequest) -> String {
    return request.URL!.absoluteString
}

public protocol ImageCaching {
    func cachedImageForRequest(request: NSURLRequest) -> UIImage?
    func cacheImage(image: UIImage, forRequest request: NSURLRequest)
}

private class ImageCache: NSCache, ImageCaching {
    private func cacheImage(image: UIImage, forRequest request: NSURLRequest) {
        setObject(image, forKey: imageCacheKeyFromURLRequest(request))
    }
    
    private func cachedImageForRequest(request: NSURLRequest) -> UIImage? {
        switch request.cachePolicy {
        case .ReloadIgnoringLocalCacheData, .ReloadIgnoringLocalAndRemoteCacheData:
            return nil
            
        default:
            break
        }
        
        return objectForKey(imageCacheKeyFromURLRequest(request)) as? UIImage
    }
}

private var OperationAssociatedObjectKey: UInt8 = 0
private let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
private let operationQueue = OperationQueue()

public extension UIImageView {
    private static let p_sharedImageCache = ImageCache()
    
    private var imageRequestOperation: Operation? {
        get {
            return objc_getAssociatedObject(self, &OperationAssociatedObjectKey) as? Operation
        }
        
        set {
            objc_setAssociatedObject(self, &OperationAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func p_setImageWithRequest(request: NSURLRequest, placeHolderImage placeholder: UIImage?) {
        if let cachedImage = ImageView.p_sharedImageCache.cachedImageForRequest(request) {
            image = cachedImage
            imageRequestOperation = nil
            postNotification()
        } else {
            if let placeholder = placeholder {
                image = placeholder
            }
            
            let task = session.dataTaskWithRequest(request) { [weak self] data, response, error in
                executeOnMainThread {
                    guard let strongSelf = self else {
                        return
                    }
                    
                    guard data != nil else {
                        return
                    }
                    guard let serializedImage = UIImage(data: data!) else {
                        return
                    }
                    
                    UIView.transitionWithView(strongSelf,
                        duration: 0.3,
                        options: UIViewAnimationOptions.TransitionCrossDissolve,
                        animations: {
                            strongSelf.image = serializedImage
                        },
                        completion: { finished in
                            if finished {
                                strongSelf.postNotification()
                            }
                        }
                    )
                    
                    UIImageView.p_sharedImageCache.cacheImage(serializedImage, forRequest: request)
                }
            }
            
            imageRequestOperation = URLSessionTaskOperation(task: task)
            imageRequestOperation?.addObserver(NetworkActivityObserver())
            operationQueue.addOperation(imageRequestOperation!)
        }
    }
    
    public func p_cancelImageRequestOperation() {
        guard let operation = imageRequestOperation else {
            return
        }
        
        operation.cancel()
    }
    
    public func p_setImageWithURL(url: NSURL) {
        p_setImageWithURL(url, placeHolderImage: nil)
    }
    
    public func p_setImageWithURL(url: NSURL, placeHolderImage placeholder: UIImage?) {
        let request = NSMutableURLRequest(URL: url)
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        request.cachePolicy = .ReturnCacheDataElseLoad
        
        p_setImageWithRequest(request, placeHolderImage: placeholder)
    }
    
    private func postNotification() {
        executeOnMainThread {
            NSNotificationCenter.defaultCenter().postNotificationName(
                kPNKDidFinishSettingImageFromURLToImageView, 
                object: self,
                userInfo: nil
            )
        }
    }
}

