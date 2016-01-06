//
//  ViewController.swift
//  CustomPop
//
//  Created by Yincheng on 16/1/4.
//  Copyright © 2016年 yc. All rights reserved.
//

import UIKit

struct Static {
    static var viewPageIndex: Int = 0
}

class ViewController: UIViewController {
    var viewTitle: String?

    deinit {
        Static.viewPageIndex = max(0, --Static.viewPageIndex)
    }

    init(viewTitle: String?) {
        super.init(nibName: nil, bundle: nil)

        self.viewTitle = viewTitle
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = self.viewTitle

        let pushBtn = UIButton(type: .System)
        pushBtn.frame = CGRectMake(130, 200, 60, 40)
        pushBtn.setTitle("Push", forState: .Normal)
        pushBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        pushBtn.addTarget(self, action: "pushController", forControlEvents: .TouchUpInside)
        self.view.addSubview(pushBtn)
    }

    func pushController() {
        let vc = ViewController(viewTitle: "Push \(++Static.viewPageIndex)")

        self.navigationController?.pushViewController(vc, animated: true)
//        self.navigationController?.showViewController(vc, sender: nil)
    }
}
