//
//  ViewController.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let width = UIScreen.main.bounds.size.width - 20 * 2
    let height = (UIScreen.main.bounds.size.width - 20 * 2) / 16.0 * 9.0
    let assetURLs: [URL] = [URL(string: "http://plvod01.videocc.net/cc84e44bdb/a/cc84e44bdb87af025cc3b6f1fd83b1da_3.flv")!]
    //    https://mpv.videocc.net/cc84e44bdb/8/cc84e44bdbcd2e2996584c3e59f13558_3.mp4
    //    http://plvod01.videocc.net/cc84e44bdb/a/cc84e44bdb87af025cc3b6f1fd83b1da_3.flv
    //    http://plvod01.videocc.net/cc84e44bdb/2/cc84e44bdb7849e24e5ae856c2187282_3.flv
    //    http://plvod01.videocc.net/cc84e44bdb/9/cc84e44bdbcdd229b44318576e857209_3.flv
    
    var player: VDPlayer?
    lazy var videoContainer: UIView = {
        return UIView(frame: CGRect(x: 20, y: 100, width:width, height:height))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoContainer.backgroundColor = .black
        view.addSubview(videoContainer)
        let coverImageView = UIImageView(frame: videoContainer.bounds)
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.layer.masksToBounds = true
        coverImageView.image = UIImage(named: "cover")
        videoContainer.addSubview(coverImageView)
        
//        let config = VDPlayerConfig(playerType: .VLCPlayer)
//        config.assetURLs = assetURLs
//        config.container = videoContainer
        
        let playBtn = UIButton(frame: videoContainer.bounds)
        playBtn.setImage(UIImage(vd_named: "play"), for: .normal)
        videoContainer.addSubview(playBtn)
        playBtn.addTarget(self, action: #selector(playBtnClick(_:)), for: .touchUpInside)
    }
    
    @objc private func playBtnClick(_ sender: UIButton) {
        let playerControl = VDVLCPlayerControl()
        let playerControlView = VDPlayerControlView()
        playerControlView.setTitle("来一个视频标题", coverURL: nil)
        playerControlView.coverImage = UIImage(named: "cover")
        player = VDPlayer(playerControl: playerControl, container: videoContainer)
        player?.controlView = playerControlView
        player?.assetURLs = assetURLs
        player?.fullScreenStateDidChange = { [weak self](player, isFullScreen) in
            self?.setNeedsStatusBarAppearanceUpdate()
            if #available(iOS 11.0, *) {
                self?.setNeedsUpdateOfHomeIndicatorAutoHidden()
            }
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
    override var prefersStatusBarHidden: Bool {
        return player?.isFullScreen ?? false
    }
    
    /// 状态栏隐藏动画
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    /// 自动旋转屏幕
    override var shouldAutorotate: Bool {
        return false
    }
    
//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//        return .landscapeRight
//    }
}

