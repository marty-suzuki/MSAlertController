//
//  UIImage+Extensions.swift
//  MSAlertController
//
//  Created by 鈴木大貴 on 2016/01/23.
//  Copyright (c) 2016年 Taiki Suzuki. All rights reserved.
//

import UIKit

extension UIImage {
    public class func image(color color: UIColor) -> UIImage {
        let frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, frame)
        CGContextSaveGState(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context)
        UIGraphicsEndImageContext()
        return image
    }
    
    public class func screenshot() -> UIImage {
        let application = UIApplication.sharedApplication()
        let imageSize = application.keyWindow?.frame.size ?? .zero
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 2)
        let context = UIGraphicsGetCurrentContext()
        application.windows.forEach {
            CGContextSaveGState(context)
            CGContextTranslateCTM(context, $0.center.x, $0.center.y)
            CGContextConcatCTM(context, $0.window?.transform ?? CGAffineTransformIdentity)
            CGContextTranslateCTM(context, -$0.bounds.size.width * $0.layer.anchorPoint.x, -$0.bounds.size.height * $0.layer.anchorPoint.y)
            $0.drawViewHierarchyInRect($0.bounds , afterScreenUpdates: true)
            CGContextRestoreGState(context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}