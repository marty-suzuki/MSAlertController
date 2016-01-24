//
//  MSTextField.swift
//  MSAlertController
//
//  Created by 鈴木大貴 on 2016/01/24.
//  Copyright (c) 2016年 Taiki Suzuki. All rights reserved.
//

import UIKit

public class MSTextField: UITextField {
    override public func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 5, 0)
    }
    
    override public func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 5, 0)
    }
}