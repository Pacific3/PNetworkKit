public typealias Image = UIImage

extension Image {
    public class func p_imageWithColor(color: UIColor) -> Image {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public class func p_roundedImageWithColor(color: UIColor, size: CGSize) -> Image {
        let circleBezierPath = UIBezierPath(rect: CGRectMake(0, 0, size.width, size.height))
        
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        
        circleBezierPath.fill()
        
        let bezierImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return bezierImage
    }
    
    public class func p_roundedImageWithColor(color: UIColor) -> Image {
        return p_roundedImageWithColor(color, size: CGSizeMake(1, 1))
    }
}
