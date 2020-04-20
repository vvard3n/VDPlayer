//
//  VDPlayerFullScreenVC.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2020/4/20.
//  Copyright © 2020 vvard3n. All rights reserved.
//

import UIKit

class VDPlayerFullScreenVC: UIViewController {
    
    var isFullScreen: Bool = false
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if isFullScreen {
            return .landscape
        }
        return .portrait
    }
    
    /// 全屏容器
    var fullScreenContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_HEIGHT, height: SCREEN_WIDTH))

//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        fullScreenContainerView.frame = view.bounds
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(fullScreenContainerView)
    }
    
    func enterFullScreen() {
        isFullScreen = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func exitFullScreen() {
        isFullScreen = false
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        setNeedsStatusBarAppearanceUpdate()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
