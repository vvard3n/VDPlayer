//
//  VDPlayer.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

protocol VDPlayerDelegate: NSObjectProtocol {
    func playerOrientationWillChange(player: VDPlayer, isFullScreen: Bool)
    func playerOrientationDidChange(player: VDPlayer, isFullScreen: Bool)
}

extension VDPlayerDelegate {
    private func playerOrientationWillChange(player: VDPlayer, isFullScreen: Bool) {}
    private func playerOrientationDidChange(player: VDPlayer, isFullScreen: Bool) {}
}

class VDPlayer: NSObject {
    weak var delegate: VDPlayerDelegate?
    
    var isFullScreen: Bool { get { return orientationObserver.isFullScreen } }
    var fullScreenStateWillChange: ((VDPlayer, Bool) -> ())?
    lazy private var orientationObserver: VDPlayerOrientationObserver = {
        let orientationObserver = VDPlayerOrientationObserver()
        orientationObserver.delegate = self
        return orientationObserver
    }()
    
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
    var controlView: (UIView & VDPlayerControlProtocol)? {
        didSet {
            guard let controlView = controlView else { return }
            controlView.player = self
            layoutSubviews()
        }
    }
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
                currentPlayerControl.playerView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
                currentPlayerControl.playbackStateDidChanged = { player, state in
                    
                }
                currentPlayerControl.playerPrepareToPlay = { player, assetURL in
                    
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
            currentPlayerControl.playerView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            currentPlayerControl.playbackStateDidChanged = { player, state in
//                if state == .playing {
//                    self.controlView = VDPlayerControlView(frame: containerView.bounds)
//                    self.controlView.player = self
//                    self.currentPlayerControl.playerView.addSubview(self.controlView)
//                }
            }
            currentPlayerControl.playerPrepareToPlay = { player, assetURL in
//                self.controlView = VDPlayerControlView(frame: containerView.bounds)
//                self.controlView.player = self
//                self.currentPlayerControl.playerView.addSubview(self.controlView)
//
//                if self.gestureControl == nil {
//                    self.gestureControl = VDPlayerGestureControl()
//                    guard let gestureControl = self.gestureControl else { return }
//                    gestureControl.delegate = self
//                    gestureControl.addGesture(to: self.controlView)
//                    return
//                }
            }
        }
    }
    
    private func layoutSubviews() {
        guard let controlView = controlView else { return }
        
        currentPlayerControl.playerView.addSubview(controlView)

//        currentPlayerControl.playerView.frame = containerView.bounds
        controlView.frame = currentPlayerControl.playerView.bounds
        controlView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
        if self.gestureControl == nil {
            self.gestureControl = VDPlayerGestureControl()
            guard let gestureControl = self.gestureControl else { return }
            gestureControl.delegate = self
            gestureControl.addGesture(to: controlView)
            return
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
        
//        isFullScreen = !isFullScreen
        
        // TODO 移入监听者
//        要监听一下全屏事件才行
        // --
        
        if isFullScreen {
            orientationObserver.exitFullScreen(animate: true)
            /*
////            var orientation = UIInterfaceOrientation.unknown
////            orientation = isFullScreen ? UIInterfaceOrientation.landscapeRight : UIInterfaceOrientation.portrait
//            //        UIApplication.shared.setStatusBarOrientation(orientation, animated: true)
//
//            if fullScreenContainerView == nil {
//                fullScreenContainerView = UIView(frame: UIApplication.shared.keyWindow?.bounds ?? CGRect.zero)
//            }
//            guard let fullScreenContainerView = fullScreenContainerView else { return }
//            currentPlayerControl.playerView.removeFromSuperview()
//            UIApplication.shared.keyWindow?.addSubview(fullScreenContainerView)
//            let rect = containerView?.convert(currentPlayerControl.playerView.frame, to: fullScreenContainerView) ?? CGRect.zero
//            fullScreenContainerView.addSubview(currentPlayerControl.playerView)
//            currentPlayerControl.playerView.frame = rect
//            UIView.animate(withDuration: 0.5, animations: {
//                self.currentPlayerControl.playerView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 90 / 360.0 * 2)
//                self.currentPlayerControl.playerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
//                self.controlView.frame = self.currentPlayerControl.playerView.bounds
//                self.fullScreenContainerView?.layoutIfNeeded()
//            }) { (complate) in
//                // 切换控制面板
//                control.portraitControlView.isHidden = self.isFullScreen
//                control.landScapeControlView.isHidden = !self.isFullScreen
//            }
            
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
//            UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.landscapeRight, animated: true)
            UIApplication.shared.statusBarOrientation = UIInterfaceOrientation.landscapeRight
//            if let block = fullScreenStateWillChange { block(self, isFullScreen) }
//
//            if fullScreenContainerView == nil {
//                fullScreenContainerView = UIView(frame: UIApplication.shared.keyWindow?.bounds ?? CGRect.zero)
//            }
//            guard let fullScreenContainerView = fullScreenContainerView else { return }
//            UIApplication.shared.keyWindow?.addSubview(fullScreenContainerView)
//
//            let rectInWindow = currentPlayerControl.playerView.convert(currentPlayerControl.playerView.bounds, to: UIApplication.shared.keyWindow)
//            currentPlayerControl.playerView.removeFromSuperview()
//            currentPlayerControl.playerView.frame = rectInWindow
//            fullScreenContainerView.addSubview(currentPlayerControl.playerView)
//
//            UIView.animate(withDuration: 0.3, animations: {
//                self.currentPlayerControl.playerView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 90 / 360.0 * 2)
//                self.currentPlayerControl.playerView.frame = CGRect(x: 0, y: 0, width: SCREEN_HEIGHT, height: SCREEN_WIDTH)
//                self.controlView.frame = self.currentPlayerControl.playerView.bounds
//                self.fullScreenContainerView?.layoutIfNeeded()
//            }) { (complate) in
//                // 切换控制面板
//                control.portraitControlView.isHidden = self.isFullScreen
//                control.landScapeControlView.isHidden = !self.isFullScreen
//            }
 */
        }
        else {
            orientationObserver.enterLandscapeFullScreen(orientation: .landscapeRight, animate: true)
            /*
//            UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.portrait, animated: true)
//            if let block = fullScreenStateWillChange { block(self, isFullScreen) }
//
//            UIView.animate(withDuration: 0.5, animations: {
//                self.currentPlayerControl.playerView.transform = CGAffineTransform.identity
//                self.currentPlayerControl.playerView.frame = self.fullScreenContainerView?.convert(self.containerView?.frame ?? .zero, to: self.fullScreenContainerView) ?? CGRect.zero
//                self.controlView.frame = self.currentPlayerControl.playerView.bounds
//                self.fullScreenContainerView?.layoutIfNeeded()
//            }) { (complate) in
//                self.currentPlayerControl.playerView.removeFromSuperview()
//                self.containerView?.insertSubview(self.currentPlayerControl.playerView, at: 1)
//                self.currentPlayerControl.playerView.frame = self.containerView?.bounds ?? CGRect.zero
//                self.fullScreenContainerView?.removeFromSuperview()
//
//                // 切换控制面板
//                control.portraitControlView.isHidden = self.isFullScreen
//                control.landScapeControlView.isHidden = !self.isFullScreen
//            }
//            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
//            CGRect frame = [self.originalView convertRect:self.originalFrame toView:[UIApplication sharedApplication].keyWindow];
//            [UIView animateWithDuration:0.3 animations:^{
//                self.transform = CGAffineTransformIdentity;
//                self.frame = frame;
//                self.mediaContainerView.frame = self.bounds;
//                self.player.view.frame = self.bounds;
//                //            self.controllView.frame = self.bounds;
//                } completion:^(BOOL finished) {
//                /*
//                 * 回到小屏位置
//                 */
//                [self removeFromSuperview];
//                self.frame = self.originalFrame;
//                self.mediaContainerView.frame = self.bounds;
//                self.player.view.frame = self.bounds;
//                //            self.controllView.frame = self.bounds;
//                [self.originalView addSubview:self];
//                //            self.state = MovieViewStateSmall;
//                }];
            guard let containerView = self.containerView else { return }
            let value = UIInterfaceOrientation.portrait.rawValue
//            UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.portrait, animated: true)
            UIApplication.shared.statusBarOrientation = UIInterfaceOrientation.portrait
            if let block = fullScreenStateWillChange { block(self, isFullScreen) }
            
//            let rectInWindow = containerView.convert(containerView.bounds, to: UIApplication.shared.keyWindow)
//            UIView.animate(withDuration: 0.3, animations: {
//                self.currentPlayerControl.playerView.transform = CGAffineTransform.identity
//                self.currentPlayerControl.playerView.frame = rectInWindow
//                self.controlView.frame = self.currentPlayerControl.playerView.bounds
//                self.fullScreenContainerView?.layoutIfNeeded()
//            }) { (complate) in
//                self.currentPlayerControl.playerView.removeFromSuperview()
//                self.containerView?.insertSubview(self.currentPlayerControl.playerView, at: 1)
//                self.currentPlayerControl.playerView.frame = self.containerView?.bounds ?? CGRect.zero
//                self.fullScreenContainerView?.removeFromSuperview()
//
//                // 切换控制面板
//                control.portraitControlView.isHidden = self.isFullScreen
//                control.landScapeControlView.isHidden = !self.isFullScreen
//            }
            */
        }
    }
}

// MARK: - OrientationObserverDelegate
extension VDPlayer: VDPlayerOrientationObserverDelegate {
    internal func orientationWillChange(observer: VDPlayerOrientationObserver, isFullScreen: Bool) {
        delegate?.playerOrientationWillChange(player: self, isFullScreen: isFullScreen)
        controlView.playerOrientationWillChanged(player: self, observer: observer)
    }
    
    internal func orientationDidChange(observer: VDPlayerOrientationObserver, isFullScreen: Bool) {
        delegate?.playerOrientationDidChange(player: self, isFullScreen: isFullScreen)
        controlView.playerOrientationDidChanged(player: self, observer: observer)
    }
}

// MARK: - Gesture
extension VDPlayer: VDPlayerGestureControlDelegate {
    internal func vd_playerGestureControlSingleTaped() {
        print("tap")
        self.controlView.gestureSingleTapped()
    }
}
