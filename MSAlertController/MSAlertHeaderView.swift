//
//  MSAlertHeaderView.swift
//  MSAlertController
//
//  Created by 鈴木大貴 on 2016/01/23.
//  Copyright (c) 2016年 Taiki Suzuki. All rights reserved.
//

import UIKit
import MisterFusion

public class MSAlertHeaderView: UIView {
    
    public let titleLabel = UILabel()
    public let messageLabel = UILabel()
    public let textFieldContentView = UIView()
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 270, height: 96))
        setupViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        titleLabel.text = "MSAlertContorller"
        titleLabel.font = .boldSystemFontOfSize(16)
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 0
        addLayoutSubview(titleLabel, andConstraints:
            titleLabel.Top |+| 22,
            titleLabel.Right |-| 18,
            titleLabel.Left |+| 18,
            titleLabel.Height |=| 16
        )
        
        messageLabel.text = "This is MSAlertController."
        messageLabel.font = .boldSystemFontOfSize(14)
        messageLabel.textAlignment = .Center
        messageLabel.numberOfLines = 0
        addLayoutSubview(messageLabel, andConstraints:
            messageLabel.Top |==| titleLabel.Bottom |+| 8,
            messageLabel.Left |+| 18,
            messageLabel.Right |-| 18,
            messageLabel.Height |=| 8
        )
        
        addLayoutSubview(textFieldContentView, andConstraints:
            textFieldContentView.Top |==| messageLabel.Bottom |+| 18,
            textFieldContentView.Right |-| 18,
            textFieldContentView.Left |+| 18,
            textFieldContentView .Bottom |-| 18
        )
    }
}