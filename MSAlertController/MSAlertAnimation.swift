//
//  MSAlertAnimation.swift
//  MSAlertController
//
//  Created by 鈴木大貴 on 2016/01/24.
//  Copyright (c) 2016年 Taiki Suzuki. All rights reserved.
//

import UIKit

public class MSAlertAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    static let AnimationDuration: NSTimeInterval = 0.25
    
    //TODO: must be private
    public var isPresenting: Bool = false
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.dynamicType.AnimationDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            executePresentingAnimation(transitionContext)
            return
        }
        executeDismissingAnimation(transitionContext)
    }
}

extension MSAlertAnimation {
    private func executePresentingAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView() else { return }
        guard let windowSize = UIApplication.sharedApplication().keyWindow?.bounds.size else { return }
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else { return }
        toViewController.view.frame = CGRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height)
        toViewController.view.alpha = 0
        if let alertController = toViewController as? MSAlertController {
            if (alertController.preferredStyle == .Alert) {
                alertController.tableViewContainer?.transform = CGAffineTransformMakeScale(1.1, 1.1)
            }
            //TODO: imageView blur aniamtion
        }
        containerView.addSubview(toViewController.view)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveEaseOut, animations: {
            toViewController.view.alpha = 1
            if let alertController = toViewController as? MSAlertController {
                if (alertController.preferredStyle == .Alert) {
                    alertController.tableViewContainer?.transform = CGAffineTransformIdentity
                }
                //TODO: imageView blur aniamtion
            }
        }) {
            if (!$0) { return }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    private func executeDismissingAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView() else { return }
        guard let windowSize = UIApplication.sharedApplication().keyWindow?.bounds.size else { return }
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else { return }
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else { return }
        toViewController.view.frame = CGRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height)
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveEaseOut, animations: {
            fromViewController.view.alpha = 0
            if let _ = toViewController as? MSAlertController {
                //TODO: imageView blur aniamtion
            }
        }) {
            if (!$0) { return }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}