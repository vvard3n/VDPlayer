//
//  VDPlayerFullScreenVC.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2020/4/20.
//  Copyright © 2020 vvard3n. All rights reserved.
//

import UIKit

class VDPlayerFullScreenVC: UIViewController {
    
    var interfaceOrientationMask: UIInterfaceOrientationMask = .allButUpsideDown
//    var isFullScreen: Bool = false
//    var animateDuration: TimeInterval = 0.3
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return interfaceOrientationMask
    }
    
    /// 全屏容器
//    var fullScreenContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_HEIGHT, height: SCREEN_WIDTH))

//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        fullScreenContainerView.frame = view.bounds
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        view.addSubview(fullScreenContainerView)
    }
    
//    func enterFullScreen() {
//        isFullScreen = true
//        setNeedsStatusBarAppearanceUpdate()
//    }
//
//    func exitFullScreen() {
//        isFullScreen = false
//        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
//        setNeedsStatusBarAppearanceUpdate()
//    }
}
