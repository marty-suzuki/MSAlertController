//
//  MSActionSheetHeaderView.swift
//  MSAlertController
//
//  Created by 鈴木大貴 on 2016/01/24.
//  Copyright (c) 2016年 Taiki Suzuki. All rights reserved.
//

import UIKit
import MisterFusion

public class MSActionSheetHeaderView: UIView {

    public let titleLabel = UILabel()
    public let messageLabel = UILabel()
    
    public var superviewTitleConstraint: NSLayoutConstraint?
    public var titleHeightConstraint: NSLayoutConstraint?
    public var titleMessageConstraint: NSLayoutConstraint?
    public var messageHeightConstraint: NSLayoutConstraint?
    public var messageSuperviewConstraint: NSLayoutConstraint?
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 270, height: 81))
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
        let titleLabelConstraints = addLayoutSubview(titleLabel, andConstraints:
            titleLabel.Top |+| 22,
            titleLabel.Right |-| 18,
            titleLabel.Left |+| 18,
            titleLabel.Height |=| 14
        )
        superviewTitleConstraint = titleLabelConstraints.firstAttribute(.Top).first
        titleHeightConstraint = titleLabelConstraints.firstAttribute(.Height).first
        
        
        messageLabel.text = "This is MSAlertController."
        messageLabel.font = .boldSystemFontOfSize(14)
        messageLabel.textAlignment = .Center
        messageLabel.numberOfLines = 0
        let messageLabelConstraints = addLayoutSubview(messageLabel, andConstraints:
            messageLabel.Top |==| titleLabel.Bottom |+| 14,
            messageLabel.Left |+| 18,
            messageLabel.Right |-| 18,
            self.Bottom |==|  messageLabel.Bottom |+| 18,
            messageLabel.Height |=| 13
        )
        titleMessageConstraint = messageLabelConstraints.firstAttribute(.Top).first
        messageHeightConstraint = messageLabelConstraints.firstAttribute(.Height).first
        messageSuperviewConstraint = messageLabelConstraints.firstItem(self).firstAttribute(.Bottom).first
        
        layoutIfNeeded()
    }
}
