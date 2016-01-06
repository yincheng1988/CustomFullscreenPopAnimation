//
//  YC_PopAnimation.swift
//  CustomPop
//
//  Created by Yincheng on 16/1/4.
//  Copyright © 2016年 yc. All rights reserved.
//

import UIKit

#if USE_OPTIONS_2

class YC_PopAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    var druation: NSTimeInterval = 0.3
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return druation
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 获取动画来自的那个控制器
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        
        // 获取转场到的那个控制器
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        let containerView = transitionContext.containerView()
        
        if let toView = toViewController?.view, fromView = fromViewController?.view {
            containerView?.insertSubview(toView, belowSubview: fromView)
        }
        
        let duration = transitionDuration(transitionContext)

        // 执行动画，让fromVC的视图移动到屏幕最右侧
        UIView.animateWithDuration(duration, animations: { () -> Void in
            fromViewController?.view.transform = CGAffineTransformMakeTranslation(UIScreen.mainScreen().bounds.size.width, 0)
            }) { (finished) -> Void in
                
                // 动画执行完成后，必须调用这个方法，否则系统会认为你的其余任何操作都在动画执行中
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

#endif