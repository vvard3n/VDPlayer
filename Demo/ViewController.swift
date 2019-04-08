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
            if isFullScreen {
//                VDObjcHandle().interfaceOrientation(.landscapeRight)
                self?.hengp()
            }
            else {
//                VDObjcHandle().interfaceOrientation(.portrait)
                self?.shup()
            }
        }
    }
    
    // MARK: - 横屏
    let appDelegate = UIApplication.shared.delegate!
    func hengp() {
//        appDelegate.blockRotation = true
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        
        UIDevice.current.setValue(value, forKey: "orientation")
        
    }
    
    // MARK: - 竖屏
    
    func shup() {
        
//        appDelegate.blockRotation = false
        
        let value = UIInterfaceOrientation.portrait.rawValue
        
        UIDevice.current.setValue(value, forKey: "orientation")
        
    }
    
    
    
    // 将要发生旋转就触发代理
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
    }
    
    // 旋转完成触发代理。我们需要在这里对必要的界面设置重新布局
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        // 获取当前手机物理状态的屏幕模式，看看是横屏还是竖屏.
        
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        
        if(interfaceOrientation == UIInterfaceOrientation.portrait) {
            //当前是在竖屏模式
            print("竖屏")
        }
        else{
            //当前是在横屏模式
//            self.theWebView?.frame = self.view.frame
        }
        
    }
    
    /// 状态栏颜色
    override var preferredStatusBarStyle: UIStatusBarStyle {
//        if player?.isFullScreen ?? false {
//            return .lightContent
//        }
        return .default
    }
    
    /// 自动隐藏Home指示器
    override var prefersHomeIndicatorAutoHidden: Bool {
        return player?.isFullScreen ?? false
    }

    /// 隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return player?.isFullScreen ?? false
    }
    
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

