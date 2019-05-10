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
    var fullScreenStateDidChange: ((VDPlayer, Bool) -> ())?
    var playbackStateDidChanged: ((VDPlayer, VDPlayerPlaybackState) -> ())?
    var loadStateDidChanged: ((VDPlayer, VDPlayerLoadState) -> ())?
    lazy private var orientationObserver: VDPlayerOrientationObserver = {
        let orientationObserver = VDPlayerOrientationObserver()
        orientationObserver.delegate = self
        return orientationObserver
    }()
    
    /// state
    var progress: Double {
        get {
            return currentTime / totalTime
        }
    }
    var currentTime: TimeInterval { get { return currentPlayerControl.currentTime } }
    var totalTime: TimeInterval { get { return currentPlayerControl.totalTime } }
    
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
            layoutPlayer()
        }
    }
    /// 手势控制器
    var gestureControl: VDPlayerGestureControl?
    
    /// 当前播放器内核
    var currentPlayerControl: VDPlayerPlayBackProtocol! {
        didSet {
            if oldValue?.isPreparedToPlay ?? false {
                oldValue?.stop()
                oldValue?.playerView.removeFromSuperview()
            }
            guard let currentPlayerControl = currentPlayerControl else { return }
            if let containerView = self.containerView {
//                containerView.insertSubview(currentPlayerControl.playerView, at: 1)
                containerView.addSubview(currentPlayerControl.playerView)
                currentPlayerControl.playerView.frame = containerView.bounds
                currentPlayerControl.playerView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
                currentPlayerControl.playbackStateDidChanged = { player, state in
                    self.playbackStateDidChanged?(self, state)
                    self.controlView?.playerPlayStateChanged(player: self, playState: state)
                }
                currentPlayerControl.loadStateDidChanged = { player, state in
                    self.controlView?.playerLoadStateChanged(player: self, loadState: state)
                }
                currentPlayerControl.playerPrepareToPlay = { player, assetURL in
                    self.layoutPlayer()
                    self.controlView?.playerPrepareToPlay(player: self)
                }
                currentPlayerControl.mediaPlayerTimeChanged = { player, currentTime, totalTime in
                    guard let controlView = self.controlView else { return }
                    controlView.updateTime(current: currentTime, total: totalTime)
                }
            }
            
        }
    }
    
    /// 数据源
    var assetURLs: [URL]? {
        didSet {
            guard let assetURLs = assetURLs else { return }
            if assetURLs.isEmpty { return }
//            currentPlayerControl.assetURL = assetURLs[0]
//            if autoPlayWhenPrepareToPlay {
                play()
//            }
        }
    }
    
    /// 是否自动播放
//    var autoPlayWhenPrepareToPlay: Bool = false
    
    override private init() {
        super.init()
        let control = VDVLCPlayerControl()
        self.currentPlayerControl = control
    }
    
//    convenience init(config: VDPlayerConfig) {
//        self.init()
//    }
    
    convenience init(playerControl: VDPlayerPlayBackProtocol, container: UIView) {
        self.init()
//        self.controlView = VDPlayerControlView()
        self.containerView = container
        self.currentPlayerControl = playerControl
        if let containerView = self.containerView {
            containerView.addSubview(self.currentPlayerControl.playerView)
//            containerView.insertSubview(self.currentPlayerControl.playerView, at: 1)
            currentPlayerControl.playerView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            currentPlayerControl.playbackStateDidChanged = { player, state in
                self.playbackStateDidChanged?(self, state)
                self.controlView?.playerPlayStateChanged(player: self, playState: state)
            }
            currentPlayerControl.loadStateDidChanged = { player, state in
                self.controlView?.playerLoadStateChanged(player: self, loadState: state)
            }
            currentPlayerControl.playerPrepareToPlay = { player, assetURL in
                self.layoutPlayer()
                self.controlView?.playerPrepareToPlay(player: self)
            }
            currentPlayerControl.mediaPlayerTimeChanged = { player, currentTime, totalTime in
                guard let controlView = self.controlView else { return }
                controlView.updateTime(current: currentTime, total: totalTime)
            }
        }
    }
    
    private func layoutPlayer() {
        guard let controlView = controlView, let containerView = containerView else { return }
        
        controlView.removeFromSuperview()
        currentPlayerControl.playerView.addSubview(controlView)
        if isFullScreen {
            currentPlayerControl.playerView.frame = fullScreenContainerView?.bounds ?? .zero
        }
        else {
            currentPlayerControl.playerView.frame = containerView.bounds
        }

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
    
    private func resetControlView() {
        guard let controlView = controlView else { return }
        controlView.reset()
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
            fullScreenContainerView?.backgroundColor = .clear
            UIView.animate(withDuration: 0.5, animations: {
                self.currentPlayerControl.playerView.transform = CGAffineTransform.identity
                self.currentPlayerControl.playerView.frame = self.fullScreenContainerView?.convert(self.containerView?.frame ?? .zero, to: self.fullScreenContainerView) ?? CGRect.zero
                self.fullScreenContainerView?.layoutIfNeeded()
            }) { (complate) in
                self.currentPlayerControl.playerView.removeFromSuperview()
//                self.containerView?.insertSubview(self.currentPlayerControl.playerView, at: 1)
                self.containerView?.addSubview(self.currentPlayerControl.playerView)
                self.currentPlayerControl.playerView.frame = self.containerView?.bounds ?? CGRect.zero
                self.fullScreenContainerView?.removeFromSuperview()
            }
            orientationObserver.exitFullScreen(animate: true)
        }
        else {
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
                self.fullScreenContainerView?.layoutIfNeeded()
            }) { (complate) in
                fullScreenContainerView.backgroundColor = .black
            }
            orientationObserver.enterLandscapeFullScreen(orientation: .landscapeRight, animate: true)
        }
    }
}

// MARK: - OrientationObserverDelegate
extension VDPlayer: VDPlayerOrientationObserverDelegate {
    internal func orientationWillChange(observer: VDPlayerOrientationObserver, isFullScreen: Bool) {
        delegate?.playerOrientationWillChange(player: self, isFullScreen: isFullScreen)
        controlView?.playerOrientationWillChanged(player: self, observer: observer)
        fullScreenStateWillChange?(self, isFullScreen)
    }
    
    internal func orientationDidChange(observer: VDPlayerOrientationObserver, isFullScreen: Bool) {
        delegate?.playerOrientationDidChange(player: self, isFullScreen: isFullScreen)
        controlView?.playerOrientationDidChanged(player: self, observer: observer)
        fullScreenStateDidChange?(self, isFullScreen)
    }
}

// MARK: - Gesture
extension VDPlayer: VDPlayerGestureControlDelegate {
    internal func vd_playerGestureControlSingleTaped() {
        print("tap")
        self.controlView?.gestureSingleTapped()
    }
    
    internal func vd_playerGestureControlDoubleTaped() {
        print("tap tap")
        self.controlView?.gestureDoubleTapped()
    }
    
    internal func vd_playerGestureControlPan(_ pan: UIPanGestureRecognizer) {
        
        print("pan")
        self.controlView?.gesturePan(pan)
    }
}

// MARK: - Media Control
extension VDPlayer {
    func seek(to time: TimeInterval, completionHandler: ((Bool) -> ())?) {
        currentPlayerControl.seek(to: time, completionHandler: completionHandler)
    }
}
