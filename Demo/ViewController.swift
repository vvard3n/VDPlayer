//
//  ViewController.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var player: VDPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let assetURLs: [URL] = [URL(string: "https://mpv.videocc.net/cc84e44bdb/8/cc84e44bdbcd2e2996584c3e59f13558_3.mp4")!]
        
        let width = UIScreen.main.bounds.size.width - 20 * 2
        let height = (UIScreen.main.bounds.size.width - 20 * 2) / 16.0 * 9.0
        
        let videoContainer = UIView(frame: CGRect(x: 20, y: 100, width:width, height:height))
        videoContainer.backgroundColor = .red
        view.addSubview(videoContainer)
        
//        let config = VDPlayerConfig(playerType: .VLCPlayer)
//        config.assetURLs = assetURLs
//        config.container = videoContainer
        
        let playerControl = VDVLCPlayerControl()
        player = VDPlayer(playerControl: playerControl, container: videoContainer)
        player?.assetURLs = assetURLs
        player?.fullScreenStateWillChange = { [weak self](player, isFullScreen) in
            self?.setNeedsStatusBarAppearanceUpdate()
            if #available(iOS 11.0, *) {
                self?.setNeedsUpdateOfHomeIndicatorAutoHidden()
            }
//            if isFullScreen {
////                VDObjcHandle().interfaceOrientation(.landscapeRight)
////                self?.hengp()
//            }
//            else {
////                VDObjcHandle().interfaceOrientation(.portrait)
////                self?.shup()
//            }
        }
    }
    
    /// 状态栏颜色
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if player?.isFullScreen ?? false {
            return .lightContent
        }
        return .default
    }
    
    /// 自动隐藏Home指示器
    override var prefersHomeIndicatorAutoHidden: Bool {
        return player?.isFullScreen ?? false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if player?.isFullScreen ?? false {
            return .landscapeRight
        }
        return .portrait
    }

    /// 隐藏状态栏
//    override var prefersStatusBarHidden: Bool {
//        return player?.isFullScreen ?? false
//    }
    
    /// 状态栏隐藏动画
//    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
//        return .fade
//    }
    
    /// 自动旋转屏幕
    override var shouldAutorotate: Bool {
        return false
    }
    
//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//        return .landscapeRight
//    }
}

