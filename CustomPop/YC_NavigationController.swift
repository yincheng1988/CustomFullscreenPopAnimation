//
//  YC_NavigationController.swift
//  CustomPop
//
//  Created by Yincheng on 16/1/5.
//  Copyright © 2016年 yc. All rights reserved.
//

import UIKit

class YC_NavigationController: UINavigationController {
    private lazy var popRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.delegate = self
        recognizer.maximumNumberOfTouches = 1
        return recognizer
    }()

#if USE_OPTIONS_2
    private lazy var interactiveTransition: YC_NavigationInteractiveTransition = YC_NavigationInteractiveTransition(navigationController: self)
#endif

    override func viewDidLoad() {
        super.viewDidLoad()

        if let gesture = self.interactivePopGestureRecognizer {
            gesture.enabled = false

            if let gestureView = gesture.view {
                gestureView.addGestureRecognizer(self.popRecognizer)
                
                #if USE_OPTIONS_2
                    setupPopTransitionWithCustom()
                #elseif USE_OPTIONS_3
                    setupPopTransitionWithSystem()
                #endif
            }
        }
    }
    
#if USE_OPTIONS_2
    private func setupPopTransitionWithCustom() {
        self.popRecognizer.addTarget(self.interactiveTransition, action: "handleControllerPop:")
    }
#endif

#if USE_OPTIONS_3
    private func setupPopTransitionWithSystem() {
        // 获取系统手势的target数组
        if let targets = self.interactivePopGestureRecognizer?.valueForKey("_targets") {
            // 获取它的唯一对象，我们知道它是一个叫UIGestureRecognizerTarget的私有类，它有一个属性叫_target
            if let gestureRecognizerTarget: AnyObject = targets.firstObject {
                // 获取_target:_UINavigationInteractiveTransition，它有一个方法叫handleNavigationTransition:
                if let navigationInteractiveTransition = gestureRecognizerTarget.valueForKey("_target") {
                    // 通过前面的打印，我们从控制台获取出来它的方法签名
                    if let handleTransition: Selector = NSSelectorFromString("handleNavigationTransition:") {
                        // 创建一个与系统一模一样的手势，我们只把它的类改为UIPanGestureRecognizer
                        self.popRecognizer.addTarget(navigationInteractiveTransition, action: handleTransition)
                    }
                }
            }
        }
    }
#endif
}

extension YC_NavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 这里有两个条件不允许手势执行，1、当前控制器为根控制器；2、如果这个push、pop动画正在执行（私有属性）
        if self.viewControllers.count > 1 {
            if let isTransition = self.valueForKey("_isTransitioning") as? Bool {
                if isTransition.boolValue == false {
                    return true
                }
            }
        }

        return false
    }
}
