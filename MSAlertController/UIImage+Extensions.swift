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
}