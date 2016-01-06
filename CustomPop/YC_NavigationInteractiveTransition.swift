//
//  YC_NavigationInteractiveTransition.swift
//  CustomPop
//
//  Created by Yincheng on 16/1/4.
//  Copyright © 2016年 yc. All rights reserved.
//

import UIKit

#if USE_OPTIONS_2

class YC_NavigationInteractiveTransition: NSObject {
    weak var navigationController: UINavigationController?
    var interactivePopTransition: UIPercentDrivenInteractiveTransition?
    
    private override init() {
        super.init()
    }

    convenience init(navigationController: UINavigationController) {
        self.init()

        self.navigationController = navigationController
        self.navigationController?.delegate = self
    }
}

extension YC_NavigationInteractiveTransition {
    /**
    *  我们把用户的每次Pan手势操作作为一次pop动画的执行
    */
    func handleControllerPop(recognizer: UIPanGestureRecognizer) {
        var progress: CGFloat = recognizer.translationInView(recognizer.view).x / (recognizer.view?.bounds.size.width)!
        
        // 稳定进度区间，让它在0.0（未完成）～1.0（已完成）之间
        progress = min(1.0, max(0.0, progress))
        
        if recognizer.state == .Began {
            // 手势开始，新建一个监控对象
            self.interactivePopTransition = UIPercentDrivenInteractiveTransition()
            
            // 告诉控制器开始执行pop的动画
            self.navigationController?.popViewControllerAnimated(true)
        } else if recognizer.state == .Changed {
            // 更新手势的完成进度
            self.interactivePopTransition?.updateInteractiveTransition(progress)
        } else if recognizer.state == .Ended || recognizer.state == .Cancelled {
            // 手势结束时如果进度大于一半，那么就完成pop操作，否则重新来过。
            if progress > 0.5 {
                self.interactivePopTransition?.finishInteractiveTransition()
            } else {
                self.interactivePopTransition?.cancelInteractiveTransition()
            }
            self.interactivePopTransition = nil
        }
    }
}

extension YC_NavigationInteractiveTransition: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 判断如果当前执行的是Pop操作，就返回我们自定义的Pop动画对象
        if operation == .Pop {
            return YC_PopAnimation()
        }
        return nil
    }

    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animationController is YC_PopAnimation {
            return self.interactivePopTransition
        }
        return nil
    }
}

#endif