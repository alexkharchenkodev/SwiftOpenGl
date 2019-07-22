//
//  UIImageExtension.swift
//  OpenGL_Test
//

import Foundation
import UIKit

extension UIImage {
    
    class func scaleImageToSize(_ img: UIImage, _ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        img.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    class func resizedImageWithinRect(_ img: UIImage, rectSize: CGSize) -> UIImage {
        let widthFactor = img.size.width / rectSize.width
        let heightFactor = img.size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if img.size.height > img.size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: img.size.width/resizeFactor, height: img.size.height/resizeFactor)
        //let resized = resizedImage(newSize)
        return scaleImageToSize(img , newSize)
    }
}
