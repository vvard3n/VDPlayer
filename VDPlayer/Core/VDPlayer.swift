//
//  VDPlayer.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit
import AVKit

@objcMembers
class VDPlayer: NSObject {
    
    /// 即将旋转屏幕方向
    var orientationWillChange: ((VDPlayer, Bool) -> ())?
    /// 已旋转屏幕方向
    var orientationDidChange: ((VDPlayer, Bool) -> ())?
    /// 播放结束
    var playerDidToEnd: ((_ player: VDPlayer) -> ())?
    /// 准备播放
    var playerPrepareToPlay: ((_ player: VDPlayer, URL) -> ())?
    
    var allowAutorotate: Bool = true {
        didSet {
            orientationObserver.allowAutorotate = allowAutorotate
        }
    }
    var isFullScreen: Bool { get { return orientationObserver.isFullScreen } }
    var playbackStateDidChanged: ((VDPlayer, VDPlayerPlaybackState) -> ())?
    var loadStateDidChanged: ((VDPlayer, VDPlayerLoadState) -> ())?
    lazy public var orientationObserver: VDPlayerOrientationObserver = {
        let orientationObserver = VDPlayerOrientationObserver()
//        orientationObserver.delegate = self
        orientationObserver.orientationWillChange = { [weak self] (observer, isFullScreen) in
            guard let weakSelf = self else { return }
//            weakSelf.delegate?.playerOrientationWillChange(player: weakSelf, isFullScreen: isFullScreen)
            weakSelf.orientationWillChange?(weakSelf, isFullScreen)
            weakSelf.controlView?.playerOrientationWillChanged(player: weakSelf, observer: observer)
            weakSelf.controlView?.setNeedsLayout()
            weakSelf.controlView?.layoutIfNeeded()
        }
        
        orientationObserver.orientationDidChange = { [weak self] (observer, isFullScreen) in
            guard let weakSelf = self else { return }
//            weakSelf.delegate?.playerOrientationDidChange(player: weakSelf, isFullScreen: isFullScreen)
            weakSelf.orientationDidChange?(weakSelf, isFullScreen)
            weakSelf.controlView?.playerOrientationDidChanged(player: weakSelf, observer: observer)
        }
        return orientationObserver
    }()
    
    /// state
    var progress: Double {
        get {
            return currentTime / totalTime
        }
    }
    var currentTime: TimeInterval { get { return currentPlayerManager.currentTime } }
    var totalTime: TimeInterval { get { return currentPlayerManager.totalTime } }
    
    /// 播放器的容器
    var containerView: UIView?
    
//    /// 全屏容器
//    var fullScreenContainerView: UIView? {
//        get {
//            return UIApplication.shared.keyWindow
//        }
//    }
    
    /// 媒体控制面板
    var controlView: (UIView & VDPlayerControlProtocol)? {
        didSet {
            guard let controlView = controlView else { return }
            controlView.player = self
            layoutPlayerSubViews()
        }
    }
    @objc func setControlView(_ controlView: UIView) {
        if let controlView = controlView as? (UIView & VDPlayerControlProtocol) {
            self.controlView = controlView
        }
    }
    /// 手势控制器
    lazy var gestureControl: VDPlayerGestureControl? = {
        let gestureControl = VDPlayerGestureControl()
        gestureControl.delegate = self
        return gestureControl
    }()
    
    /// 当前播放器内核
    var currentPlayerManager: VDPlayerPlayBackProtocol! {
        didSet {
            if oldValue?.isPreparedToPlay ?? false {
                oldValue?.stop()
                oldValue?.view.removeFromSuperview()
                removeDeviceOrientationObserver()
//                gestureControl?.removeGesture(from: currentPlayerManager.view)
            }
            guard let currentPlayerManager = currentPlayerManager else { return }
            guard let containerView = self.containerView else { return }
//            gestureControl?.addGesture(to: currentPlayerManager.view)
            containerView.addSubview(currentPlayerManager.view)
            currentPlayerManager.playbackStateDidChanged = { [weak self] player, state in
                guard let weakSelf = self else { return }
                if state == .stopped {
                    weakSelf.stop()
                }
                weakSelf.playbackStateDidChanged?(weakSelf, state)
                weakSelf.controlView?.playerPlayStateChanged(player: weakSelf, playState: state)
            }
            currentPlayerManager.loadStateDidChanged = { [weak self] player, state in
                guard let weakSelf = self else { return }
                weakSelf.controlView?.playerLoadStateChanged(player: weakSelf, loadState: state)
            }
            currentPlayerManager.playerReadyToPlay = { player, assetURL in
                do { try AVAudioSession.sharedInstance().setCategory(.playback, options: .allowBluetooth) } catch { }
                do { try AVAudioSession.sharedInstance().setActive(true, options: []) } catch { }
            }
            currentPlayerManager.playerPrepareToPlay = { [weak self] player, assetURL in
                guard let weakSelf = self else { return }
                weakSelf.addDeviceOrientationObserver()
                weakSelf.layoutPlayerSubViews()
                weakSelf.controlView?.playerPrepareToPlay(player: weakSelf)
                weakSelf.playerPrepareToPlay?(weakSelf, assetURL)
            }
            currentPlayerManager.mediaPlayerTimeChanged = { [weak self] player, currentTime, totalTime in
                guard let weakSelf = self else { return }
                guard let controlView = weakSelf.controlView else { return }
                controlView.updateTime(current: currentTime, total: totalTime)
            }
            controlView?.player = self
            layoutPlayerSubViews()
            if currentPlayerManager.isPreparedToPlay {
                addDeviceOrientationObserver()
            }
            orientationObserver.update(rotateView: currentPlayerManager.view, containerView: containerView)
        }
    }
    
    /// 数据源
    var assetURLs: [URL]? {
        didSet {
            guard let assetURLs = assetURLs else { return }
            if assetURLs.isEmpty { return }
//            currentPlayerControl.assetURL = assetURLs[0]
            if autoPlayWhenPrepareToPlay {
                play()
            }
        }
    }
    
    /// 是否自动播放
    var autoPlayWhenPrepareToPlay: Bool = true
    
    /// 播放结束是否退出全屏
    var exitFullScreenWhenStop: Bool = false
    
    deinit {
        currentPlayerManager.stop()
    }
    
    override private init() {
        super.init()
    }
    
    @objc public init(playerControl: VDPlayerPlayBackProtocol, container: UIView) {
        super.init()
        setContainerView(container)
        setPlayerControl(playerControl)
    }
    
    private func setPlayerControl(_ playerControl: VDPlayerPlayBackProtocol) {
        self.currentPlayerManager = playerControl
    }
    
    
    private func setContainerView(_ containerView: UIView) {
        self.containerView = containerView
        self.containerView?.isUserInteractionEnabled = true
    }
    
    private func layoutPlayerSubViews() {
        guard let controlView = controlView, let containerView = containerView else { return }
        
        gestureControl?.removeGesture(from: controlView)
        gestureControl?.addGesture(to: controlView)
        
        controlView.removeFromSuperview()
        currentPlayerManager.view.addSubview(controlView)
        if isFullScreen {
            currentPlayerManager.view.frame = orientationObserver.fullScreenContainerView?.bounds ?? .zero
            orientationObserver.fullScreenContainerView?.addSubview(currentPlayerManager.view)
        }
        else {
            currentPlayerManager.view.frame = containerView.bounds
            containerView.addSubview(currentPlayerManager.view)
        }
        currentPlayerManager.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        controlView.frame = currentPlayerManager.view.bounds
        controlView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
        orientationObserver.update(rotateView: currentPlayerManager.view, containerView: containerView)
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
        
        currentPlayerManager.assetURL = assetURLs[index]
    }
    
    func playNext() {
        
    }
    
    func playPrevious() {
        
    }
    
    @objc func pause() {
        currentPlayerManager.pause()
    }
    
    func stop() {
        if isFullScreen && exitFullScreenWhenStop {
            orientationObserver.enterFullScreen(false, animated: true) { (complete) in
                self.currentPlayerManager.stop()
                self.currentPlayerManager.view.removeFromSuperview()
            }
        }
        else if isFullScreen {
            currentPlayerManager.stop()
        }
        else {
            currentPlayerManager.stop()
            currentPlayerManager.view.removeFromSuperview()
        }
        removeDeviceOrientationObserver()
    }
}

// MARK: - Rotate
extension VDPlayer {
    
    func addDeviceOrientationObserver() {
        orientationObserver.addDeviceOrientationObserver()
    }
    
    func removeDeviceOrientationObserver() {
        orientationObserver.removeDeviceOrientationObserver()
    }
    
    func fullScreenStateChange(animated: Bool) {
        let control = controlView as! VDPlayerControlView
        control.controlViewAppeared = false
        control.hideControlView(animated: true)
    }
    
    func rotateToOrientation(_ orientation: UIInterfaceOrientation, animated: Bool, completion:((_ completion: Bool)->())? = nil) {
        orientationObserver.fullScreenMode = .landscape
        orientationObserver.rotate(to: orientation, animated: animated, completion: completion)
    }
    
    func enterFullScreen(_ fullScreen: Bool, animated: Bool, completion:((_ completion: Bool)->())? = nil) {
        fullScreenStateChange(animated: animated)
        if orientationObserver.fullScreenMode == .portrait {
            orientationObserver.enterPortraitMode(fullScreen: fullScreen, animated: animated, completion: completion)
        }
        else {
            var orientation = UIInterfaceOrientation.unknown
            orientation = fullScreen ? .landscapeRight : .portrait
            orientationObserver.rotate(to: orientation, animated: animated, completion: completion)
        }
    }
    
    func enterPortraitFullScreen(_ fullScreen: Bool, animated: Bool, completion:((_ completion: Bool)->())? = nil) {
        orientationObserver.fullScreenMode = .portrait
        orientationObserver.enterPortraitMode(fullScreen: fullScreen, animated: animated, completion: completion)
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
        currentPlayerManager.seek(to: time, completionHandler: completionHandler)
    }
}
