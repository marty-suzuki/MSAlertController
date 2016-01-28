//
//  MSAlertController.swift
//  MSAlertController
//
//  Created by 鈴木大貴 on 2016/01/29.
//  Copyright (c) 2016年 Taiki Suzuki. All rights reserved.
//

import UIKit
import MisterFusion

extension MSAlertControllerStyle {
    var nibName: String {
        switch self {
        case .Alert:
            return "MSAlertController_ActionSheet"
        case .ActionSheet:
            return "MSAlertController"
        }
    }
}

//MARK: - Public
public extension MSAlertController {
    public func addTextField(configurationHandler configurationHandler: ((UITextField) -> Void)?) {
        if (preferredStyle == .ActionSheet) {
            let _ = NSException(name: "NSInternalInconsistencyException", reason: "Text fields can only be added to an alert controller of style MSAlertControllerStyleAlert", userInfo: nil)
            return
        }
        
        guard var textFields = textFields as? [UITextField] else { return }
        let textField = MSTextField()
        textField.borderStyle = .None
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.grayColor().CGColor
        textField.delegate = self
        configurationHandler?(textField)
        textFields += [textField]
        self.textFields = textFields
    }
    
    public func addAction(action: MSAlertAction) {
        guard var actions = actions as? [MSAlertAction] else { return }
        if action.style == .Cancel {
            for act in actions {
                if act.style == .Cancel {
                    let _ = NSException(name: "NSInternalInconsistencyException", reason: "MSAlertController can only have one action with a style of MSAlertActionStyleCancel", userInfo: nil)
                    return
                }
            }
        }
        
        actions += [action]
        let lastIndex = actions.count - 1
        for (index, act) in actions.enumerate() {
            guard act.style == .Cancel && index != lastIndex else { continue }
            swap(&actions[index], &actions[lastIndex])
            break
        }
        self.actions = actions
    }
}

//MARK: - UITextFieldDelegate
extension MSAlertController: UITextFieldDelegate {
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.canResignFirstResponder() {
            textField.resignFirstResponder()
            dismissViewControllerAnimated(true, completion: nil)
        }
        return true
    }
}

//MARK: - UIViewControllerTransitioningDelegate
extension MSAlertController: UIViewControllerTransitioningDelegate {
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animation.isPresenting = true;
        return animation
    }
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animation.isPresenting = false
        return animation
    }
}

//MARK: - UITableViewDelegate
extension MSAlertController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        guard let action = actions[indexPath.row] as? MSAlertAction else { return }
        action.handler?(action)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch preferredStyle {
            case .ActionSheet:
                actionSheetHeaderView?.layoutIfNeeded()
                return actionSheetHeaderView?.frame.size.height ?? 0
            case .Alert:
                alertHeaderView?.layoutIfNeeded()
                return alertHeaderView?.frame.size.height ?? 0
        }
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch preferredStyle {
            case .ActionSheet:
                actionSheetHeaderView?.backgroundColor = alertBackgroundColor
                return actionSheetHeaderView
            case .Alert:
                alertHeaderView?.backgroundColor = alertBackgroundColor
                return alertHeaderView
        }
    }
}

//MARK: - UITableViewDataSource
extension MSAlertController: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = cancelAction() where preferredStyle == .ActionSheet {
            return actions.count - 1
        }
        return actions.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        let action = actions[indexPath.row] as! MSAlertAction
        
        let titleLabel = cell.contentView.viewWithTag(10001) as? UILabel ?? UILabel()
        titleLabel.text = action.title
        titleLabel.textColor = action.titleColor
        titleLabel.font = action.font
        titleLabel.textAlignment = .Center
        titleLabel.tag = 10001
        cell.contentView.addLayoutSubview(titleLabel, andConstraints:
            titleLabel.Top, titleLabel.Left, titleLabel.Right, titleLabel.Bottom
        )
        
        cell.separatorInset = UIEdgeInsetsZero
        if #available(iOS 8, *) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
            
        cell.userInteractionEnabled = action.enabled
        if !action.enabled {
            titleLabel.textColor = .blackColor()//disabledColor
        }
        
        cell.backgroundColor = action.normalColor ?? alertBackgroundColor
        
        if let highlightedColor = action.highlightedColor {
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = highlightedColor
            cell.selectedBackgroundView = selectedBackgroundView
        }
        return cell
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

//public extension MSAlertController {
//    public convenience init(title: String, message: String, preferredStyle: MSAlertControllerStyle) {
//        let url = NSBundle(forClass: MSAlertController.self).URLForResource("MSAlertController", withExtension: "bundle")
//        self.init(nibName: preferredStyle.nibName, bundle: NSBundle(URL: url!))
//        
//        self.transitioningDelegate = self
//        self.title = title
//        self.message = message
//        
//        switch preferredStyle {
//            case .Alert:
//                self.titleColor = .blackColor()
//                self.titleFont = .boldSystemFontOfSize(16)
//                self.messageColor  = .blackColor()
//                self.messageFont = .systemFontOfSize(14)
//            case .ActionSheet:
//                self.titleColor = UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1)
//                self.titleFont = .boldSystemFontOfSize(14)
//                self.messageColor = UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1)
//                self.messageFont = .systemFontOfSize(13)
//        }
//        
//        self.actions = []
//        self.textFields = []
//        self.animation = MSAlertAnimation()
//        self.preferredStyle = preferredStyle
//        self.enabledBlurEffect = true
//        self.backgroundColor = .grayColor()
//        self.alpha = 0.5
//        self.alertBackgroundColor = .whiteColor()
//        self.separatorColor = UIColor(red: 131/255, green: 131/255, blue: 131/255, alpha: 1)
//        
//        switch preferredStyle {
//            case .Alert:
//                self.alertHeaderView = MSAlertHeaderView()
//            case .ActionSheet:
//                self.actionSheetHeaderView = MSActionSheetHeaderView()
//        }
//    }
//}