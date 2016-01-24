//
//  MSAlertAction.swift
//  MSAlertController
//
//  Created by 鈴木大貴 on 2016/01/23.
//  Copyright (c) 2016年 Taiki Suzuki. All rights reserved.
//

import UIKit

public class MSAlertAction: NSObject, NSCopying {
    
    private let DefaultFonts: [MSAlertActionStyle : UIFont] = [
        .Destructive : .systemFontOfSize(18),
        .Default : .systemFontOfSize(18),
        .Cancel : .boldSystemFontOfSize(18)
    ]
    private let DefaultColors: [MSAlertActionStyle : UIColor] = [
        .Destructive : UIColor(red:1, green:59.0/255.0, blue:48.0/255.0, alpha:1),
        .Default : UIColor(red:0, green:122.0/255.0, blue:1, alpha:1),
        .Cancel : UIColor(red:0, green:122.0/255.0, blue:1, alpha:1)
    ]
    
    public typealias MSAlertActionHandler = MSAlertAction -> Void
    
    public private(set) var title: String?
    public private(set) var style: MSAlertActionStyle = .Default
    public var enabled: Bool = true {
        didSet {
            if enabled != oldValue {
                NSNotificationCenter.defaultCenter().postNotificationName(kAlertActionChangeEnabledProperty, object: nil)
            }
        }
    }
    public var titleColor: UIColor?
    public var font: UIFont?
    public var normalColor: UIColor?
    public var highlightedColor: UIColor?
    public private(set) var handler: MSAlertActionHandler?
    
    public class func action(title title: String?, style: MSAlertActionStyle, handler: MSAlertActionHandler?) -> MSAlertAction {
        return MSAlertAction(title: title, style: style, handler: handler)
    }
    
    public init(title: String?, style: MSAlertActionStyle, handler: MSAlertActionHandler?) {
        super.init()
        self.title = title
        self.style = style
        self.handler =  handler
        self.font = DefaultFonts[style]
        self.titleColor = DefaultColors[style]
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let action = MSAlertAction(title: title, style: style, handler: handler)
        action.font = font
        action.titleColor = titleColor
        action.enabled = enabled
        return action
    }
}
