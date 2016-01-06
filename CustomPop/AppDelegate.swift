//
//  AppDelegate.swift
//  CustomPop
//
//  Created by Yincheng on 16/1/4.
//  Copyright © 2016年 yc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()

        #if USE_OPTIONS_1
            //  https://github.com/forkingdog
            //  http://nshipster.cn/swift-objc-runtime/
            window?.rootViewController = UINavigationController(rootViewController: ViewController(viewTitle: "UINavigationController"))
        #elseif USE_OPTIONS_2
            // http://www.jianshu.com/p/d39f7d22db6c#fn_link_1
            // https://github.com/zys456465111/CustomPopAnimation
            window?.rootViewController =
                YC_NavigationController(rootViewController: ViewController(viewTitle: "YC_NavigationController"))
        #elseif USE_OPTIONS_3
            window?.rootViewController =
                YC_NavigationController(rootViewController: ViewController(viewTitle: "YC_NavigationController"))
        #endif

        window?.makeKeyAndVisible()

        return true
    }
}

