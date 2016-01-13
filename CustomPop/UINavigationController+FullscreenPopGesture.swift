//
//  UINavigationController+FullscreenPopGesture.swift
//  CustomPop
//
//  Created by Yincheng on 16/1/5.
//  Copyright © 2016年 yc. All rights reserved.
//
//

import UIKit

#if USE_EXTENSION_1

private class _FDFullscreenPopGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    weak var navigationController: UINavigationController?

    @objc func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.navigationController?.viewControllers.count <= 1 {
            return false
        }

        let topViewController = self.navigationController?.viewControllers.last

        if topViewController!.fd_interactivePopDisabled {
            return false
        }

        // Ignore when the beginning location is beyond max allowed initial distance to left edge.
        let beginningLocation = gestureRecognizer.locationInView(gestureRecognizer.view)
        let maxAllowedInitialDistance = topViewController!.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge
        if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance) {
            return false
        }

        // Ignore pan gesture when the navigation controller is currently in transition.
        let isTransition = self.navigationController?.valueForKey("_isTransitioning") as? Bool
        if isTransition != nil && isTransition! == true {
            return false
        }

        // Prevent calling the handler when the gesture begins in an opposite direction.
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = gestureRecognizer.translationInView(gestureRecognizer.view)
            if translation.x <= 0 {
                return false
            }
        }

        return true
    }
}

private typealias _FDViewControllerWillAppearInjectBlock = ((UIViewController, Bool) -> Void)

extension UIViewController {
    private class _FDInjectBlockWrapper {
        var value: _FDViewControllerWillAppearInjectBlock?
        init(_ value: _FDViewControllerWillAppearInjectBlock?) {
            self.value = value
        }
    }

    private struct  fd_UIViewController_Static {
        static var token: dispatch_once_t = 0;

        static var fd_willAppearInjectBlock = "fd_willAppearInjectBlock"
        static var fd_interactivePopDisabled = "fd_interactivePopDisabled"
        static var fd_prefersNavigationBarHidden = "fd_prefersNavigationBarHidden"
        static var fd_interactivePopMaxAllowedInitialDistanceToLeftEdge = "fd_interactivePopMaxAllowedInitialDistanceToLeftEdge"
    }

    private var fd_willAppearInjectBlock: _FDViewControllerWillAppearInjectBlock? {
        get {
            if let closure = objc_getAssociatedObject(self, &fd_UIViewController_Static.fd_willAppearInjectBlock) as? _FDInjectBlockWrapper {
                return closure.value
            }
            return nil
        }
        set {
            objc_setAssociatedObject(
                self,
                &fd_UIViewController_Static.fd_willAppearInjectBlock,
                _FDInjectBlockWrapper(newValue),
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    public var fd_interactivePopDisabled: Bool {
        get {
            if let disabled = objc_getAssociatedObject(self, &fd_UIViewController_Static.fd_interactivePopDisabled) as? Bool {
                return disabled
            } else {
                let disabled = false
                objc_setAssociatedObject(
                    self,
                    &fd_UIViewController_Static.fd_interactivePopDisabled,
                    disabled,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return disabled
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &fd_UIViewController_Static.fd_interactivePopDisabled,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    public var fd_prefersNavigationBarHidden: Bool {
        get {
            if let hidden = objc_getAssociatedObject(self, &fd_UIViewController_Static.fd_prefersNavigationBarHidden) as? Bool {
                return hidden
            } else {
                let hidden = false
                objc_setAssociatedObject(
                    self,
                    &fd_UIViewController_Static.fd_prefersNavigationBarHidden,
                    hidden,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return hidden
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &fd_UIViewController_Static.fd_prefersNavigationBarHidden,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    public var fd_interactivePopMaxAllowedInitialDistanceToLeftEdge: CGFloat {
        get {
            if let edge = objc_getAssociatedObject(self, &fd_UIViewController_Static.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge) as? CGFloat {
                return edge
            } else {
                objc_setAssociatedObject(
                    self,
                    &fd_UIViewController_Static.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge,
                    0,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return 0
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &fd_UIViewController_Static.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge,
                max(0, newValue),
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }


    public override class func initialize() {
        dispatch_once(&fd_UIViewController_Static.token) { () -> Void in
            let originalSelector = Selector("viewWillAppear:")
            let swizzledSelector = Selector("fd_viewWillAppear:")

            let originMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

            let success = class_addMethod(
                self,
                originalSelector,
                method_getImplementation(swizzledMethod),
                method_getTypeEncoding(swizzledMethod)
            )

            if success {
                class_replaceMethod(
                    self,
                    swizzledSelector,
                    method_getImplementation(originMethod),
                    method_getTypeEncoding(originMethod)
                )
            } else {
                method_exchangeImplementations(originMethod, swizzledMethod)
            }
        }
    }
    
    func fd_viewWillAppear(animated: Bool) {
        self.fd_viewWillAppear(animated)

        self.fd_willAppearInjectBlock?(self, animated)
    }
}

extension UINavigationController {
    private struct fd_UINavigationController_Static {
        static var token: dispatch_once_t = 0

        static var fd_fullscreenPopGestureRecognizer = "fd_fullscreenPopGestureRecognizer"
        static var fd_viewControllerBasedNavigationBarAppearanceEnabled = "fd_viewControllerBasedNavigationBarAppearanceEnabled"
        static var fd_popGestureRecognizerDelegate = "fd_popGestureRecognizerDelegate"
    }

    private(set) public var fd_fullscreenPopGestureRecognizer: UIPanGestureRecognizer {
        get {
            if let recognizer = objc_getAssociatedObject(self, &fd_UINavigationController_Static.fd_fullscreenPopGestureRecognizer) as? UIPanGestureRecognizer {
                return recognizer
            } else {
                let recognizer = UIPanGestureRecognizer()
                recognizer.maximumNumberOfTouches = 1

                objc_setAssociatedObject(
                    self,
                    &fd_UINavigationController_Static.fd_fullscreenPopGestureRecognizer,
                    recognizer,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return recognizer
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &fd_UINavigationController_Static.fd_fullscreenPopGestureRecognizer,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    public var fd_viewControllerBasedNavigationBarAppearanceEnabled: Bool {
        get {
            if let enabled = objc_getAssociatedObject(self, &fd_UINavigationController_Static.fd_viewControllerBasedNavigationBarAppearanceEnabled) as? Bool {
                return enabled
            } else {
                let enabled = true
                objc_setAssociatedObject(
                    self,
                    &fd_UINavigationController_Static.fd_viewControllerBasedNavigationBarAppearanceEnabled,
                    enabled,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return enabled
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &fd_UINavigationController_Static.fd_viewControllerBasedNavigationBarAppearanceEnabled,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    public override class func initialize() {
        dispatch_once(&fd_UINavigationController_Static.token) { () -> Void in
            let originalSelector = Selector("pushViewController:animated:")
            let swizzledSelector = Selector("fd_pushViewController:animated:")
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

            let success = class_addMethod(
                self,
                originalSelector,
                method_getImplementation(swizzledMethod),
                method_getTypeEncoding(swizzledMethod)
            )

            if success {
                class_replaceMethod(
                    self,
                    swizzledSelector,
                    method_getImplementation(originalMethod),
                    method_getTypeEncoding(originalMethod)
                )
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }

    func fd_pushViewController(viewController: UIViewController, animated: Bool) {
        if let popGestureRecognizer = self.interactivePopGestureRecognizer {
            if let view = popGestureRecognizer.view {
                if let recognizers = view.gestureRecognizers {
                    if !recognizers.contains(self.fd_fullscreenPopGestureRecognizer) {
                        // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
                        view.addGestureRecognizer(self.fd_fullscreenPopGestureRecognizer)
                    }
                }
            }

            // Forward the gesture events to the private handler of the onboard gesture recognizer.
            if let internalTargets = popGestureRecognizer.valueForKey("targets") as? [AnyObject] {
                if let internalTarget = internalTargets.first?.valueForKey("target") {
                    if let internalAction: Selector = Selector("handleNavigationTransition:") {
                        self.fd_fullscreenPopGestureRecognizer.delegate = self.fd_popGestureRecognizerDelegate()
                        self.fd_fullscreenPopGestureRecognizer.addTarget(internalTarget, action: internalAction)
                    }
                }
            }

            // Disable the onboard gesture recognizer.
            popGestureRecognizer.enabled = false
        }

        // Handle perferred navigation bar appearance.
        self.fd_setupViewControllerBasedNavigationBarAppearanceIfNeeded(viewController)

        // Forward to primary implementation.
        if !self.viewControllers.contains(viewController) {
            self.fd_pushViewController(viewController, animated: animated)
        }
    }

    private func fd_setupViewControllerBasedNavigationBarAppearanceIfNeeded(appearingViewController: UIViewController) {
        if !self.fd_viewControllerBasedNavigationBarAppearanceEnabled {
            return
        }
        
        let block: _FDViewControllerWillAppearInjectBlock = {[weak self](viewController, animated) in
            self?.setNavigationBarHidden(viewController.fd_prefersNavigationBarHidden, animated: animated)
        }

//         Setup will appear inject block to appearing view controller.
//         Setup disappearing view controller as well, because not every view controller is added into
//         stack by pushing, maybe by "-setViewControllers:".
        appearingViewController.fd_willAppearInjectBlock = block

        if let disappearingViewController = self.viewControllers.last {
            if disappearingViewController.fd_willAppearInjectBlock == nil {
                disappearingViewController.fd_willAppearInjectBlock = block
            }
        }
    }

    private func fd_popGestureRecognizerDelegate() -> _FDFullscreenPopGestureRecognizerDelegate {
        if let delegate = objc_getAssociatedObject(self, &fd_UINavigationController_Static.fd_popGestureRecognizerDelegate) as? _FDFullscreenPopGestureRecognizerDelegate {
            return delegate
        } else {
            let delegate = _FDFullscreenPopGestureRecognizerDelegate()
            delegate.navigationController = self

            objc_setAssociatedObject(
                self,
                &fd_UINavigationController_Static.fd_popGestureRecognizerDelegate,
                delegate,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            return delegate
        }
    }
}

#endif
