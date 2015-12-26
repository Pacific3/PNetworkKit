public typealias Image = UIImage

extension Image {
    public class func p_imageWithColor(color: Color) -> Image {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public class func p_imageWithColor<C: ColorConvertible>(color: C) -> Image {
        return p_imageWithColor(color.color())
    }
    
    public class func p_roundedImageWithColor(color: Color, size: CGSize) -> Image {
        let circleBezierPath = UIBezierPath(rect: CGRectMake(0, 0, size.width, size.height))
        
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        
        circleBezierPath.fill()
        
        let bezierImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return bezierImage
    }
    
    public class func p_roundedImageWithColor<C: ColorConvertible>(color: C, size: CGSize) -> Image {
        return p_roundedImageWithColor(color.color(), size: size)
    }
    
    public class func p_roundedImageWithColor(color: Color) -> Image {
        return p_roundedImageWithColor(color, size: CGSizeMake(1, 1))
    }
    
    public class func p_roundedImageWithColor<C: ColorConvertible>(color: C) -> Image {
        return p_roundedImageWithColor(color, size: CGSizeMake(1, 1))
    }
}
