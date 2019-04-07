//
//  VDPlayer.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class VDPlayer: NSObject {
    
    var isFullScreen: Bool = false
    var fullScreenStateWillChange: ((VDPlayer, Bool) -> ())?
    
    /// 播放器的容器
    var containerView: UIView? {
        didSet {
            guard let containerView = containerView else { return }
            containerView.addSubview(self.currentPlayerControl.playerView)
        }
    }
    
    /// 全屏容器
    var fullScreenContainerView: UIView?
    
    /// 媒体控制面板
    var controlView: (UIView & VDPlayerControlProtocol)!
    /// 手势控制器
    var gestureControl: VDPlayerGestureControl?
    
    /// 当前播放器内核
    var currentPlayerControl: VDPlayerPlayBackControl! {
        didSet {
            if oldValue?.isPreparedToPlay ?? false {
                oldValue?.stop()
                oldValue?.playerView.removeFromSuperview()
            }
            guard let currentPlayerControl = currentPlayerControl else { return }
            if let containerView = self.containerView {
                containerView.insertSubview(currentPlayerControl.playerView, at: 1)
                currentPlayerControl.playerView.frame = containerView.bounds
                currentPlayerControl.playbackStateDidChanged = { player, state in
                    
                }
                currentPlayerControl.playerPrepareToPlay = { player, assetURL in
                    self.controlView = VDPlayerControlView(frame: containerView.bounds)
                    self.controlView.player = self
                    currentPlayerControl.playerView.addSubview(self.controlView)
                    
                    if self.gestureControl == nil {
                        self.gestureControl = VDPlayerGestureControl()
                        guard let gestureControl = self.gestureControl else { return }
                        gestureControl.delegate = self
                        gestureControl.addGesture(to: self.controlView)
                        return
                    }
                }
            }
            
        }
    }
    
    /// 数据源
    var assetURLs: [URL]? {
        didSet {
            play()
        }
    }
//    weak var delegate
    
    override private init() {
        super.init()
        let control = VDVLCPlayerControl()
        self.currentPlayerControl = control
    }
    
//    convenience init(config: VDPlayerConfig) {
//        self.init()
//    }
    
    convenience init(playerControl: VDPlayerPlayBackControl, container: UIView) {
        self.init()
//        self.controlView = VDPlayerControlView()
        self.containerView = container
        self.currentPlayerControl = playerControl
        if let containerView = self.containerView {
//            containerView.addSubview(self.currentPlayerControl.playerView)
            containerView.insertSubview(self.currentPlayerControl.playerView, at: 1)
            currentPlayerControl.playerView.frame = containerView.bounds
            currentPlayerControl.playbackStateDidChanged = { player, state in
//                if state == .playing {
//                    self.controlView = VDPlayerControlView(frame: containerView.bounds)
//                    self.controlView.player = self
//                    self.currentPlayerControl.playerView.addSubview(self.controlView)
//                }
            }
            currentPlayerControl.playerPrepareToPlay = { player, assetURL in
                self.controlView = VDPlayerControlView(frame: containerView.bounds)
                self.controlView.player = self
                self.currentPlayerControl.playerView.addSubview(self.controlView)
                
                if self.gestureControl == nil {
                    self.gestureControl = VDPlayerGestureControl()
                    guard let gestureControl = self.gestureControl else { return }
                    gestureControl.delegate = self
                    gestureControl.addGesture(to: self.controlView)
                    return
                }
            }
        }
    }
}

/// control
extension VDPlayer {
    func play() {
        if containerView == nil { return }
        play(index: 0)
    }
    
    func play(index: Int) {
        guard let assetURLs = assetURLs else { return }
        if assetURLs.isEmpty { return }
        if index > assetURLs.count - 1 { return }
        
        currentPlayerControl.assetURL = assetURLs[index]
    }
    
    func playNext() {
        
    }
    
    func playPrevious() {
        
    }
    
    func fullScreenStateChange(animated: Bool) {
        let control = controlView as! VDPlayerControlView
        control.controlViewAppeared = false
        control.hideControlView(animated: true)
        
        isFullScreen = !isFullScreen
        
        // TODO 移入监听者
//        要监听一下全屏事件才行
        // --
        
        if isFullScreen {
//            var orientation = UIInterfaceOrientation.unknown
//            orientation = isFullScreen ? UIInterfaceOrientation.landscapeRight : UIInterfaceOrientation.portrait
            //        UIApplication.shared.setStatusBarOrientation(orientation, animated: true)
            if let block = fullScreenStateWillChange { block(self, isFullScreen) }
            
            if fullScreenContainerView == nil {
                fullScreenContainerView = UIView(frame: UIApplication.shared.keyWindow?.bounds ?? CGRect.zero)
            }
            guard let fullScreenContainerView = fullScreenContainerView else { return }
            currentPlayerControl.playerView.removeFromSuperview()
            UIApplication.shared.keyWindow?.addSubview(fullScreenContainerView)
            let rect = containerView?.convert(currentPlayerControl.playerView.frame, to: fullScreenContainerView) ?? CGRect.zero
            fullScreenContainerView.addSubview(currentPlayerControl.playerView)
            currentPlayerControl.playerView.frame = rect
            UIView.animate(withDuration: 0.5, animations: {
                self.currentPlayerControl.playerView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 90 / 360.0 * 2)
                self.currentPlayerControl.playerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                self.controlView.frame = self.currentPlayerControl.playerView.bounds
                self.fullScreenContainerView?.layoutIfNeeded()
            }) { (complate) in
                // 切换控制面板
                control.portraitControlView.isHidden = self.isFullScreen
                control.landScapeControlView.isHidden = !self.isFullScreen
            }
        }
        else {
            if let block = fullScreenStateWillChange { block(self, isFullScreen) }
            
            UIView.animate(withDuration: 0.5, animations: {
                self.currentPlayerControl.playerView.transform = CGAffineTransform.identity
                self.currentPlayerControl.playerView.frame = self.fullScreenContainerView?.convert(self.containerView?.frame ?? .zero, to: self.fullScreenContainerView) ?? CGRect.zero
                self.controlView.frame = self.currentPlayerControl.playerView.bounds
                self.fullScreenContainerView?.layoutIfNeeded()
            }) { (complate) in
                self.currentPlayerControl.playerView.removeFromSuperview()
                self.containerView?.insertSubview(self.currentPlayerControl.playerView, at: 1)
                self.currentPlayerControl.playerView.frame = self.containerView?.bounds ?? CGRect.zero
                self.fullScreenContainerView?.removeFromSuperview()
                
                // 切换控制面板
                control.portraitControlView.isHidden = self.isFullScreen
                control.landScapeControlView.isHidden = !self.isFullScreen
            }
        }
    }
}

// MARK: - Gesture
extension VDPlayer: VDPlayerGestureControlDelegate {
    func vd_playerGestureControlSingleTaped() {
        print("tap")
        self.controlView.gestureSingleTapped()
    }
}
