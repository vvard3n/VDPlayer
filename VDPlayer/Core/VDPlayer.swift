//
//  VDPlayer.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit
import AVKit

protocol VDPlayerDelegate: NSObjectProtocol {
    func playerOrientationWillChange(player: VDPlayer, isFullScreen: Bool)
    func playerOrientationDidChange(player: VDPlayer, isFullScreen: Bool)
}

extension VDPlayerDelegate {
    private func playerOrientationWillChange(player: VDPlayer, isFullScreen: Bool) {}
    private func playerOrientationDidChange(player: VDPlayer, isFullScreen: Bool) {}
}

@objcMembers
class VDPlayer: NSObject {
    weak var delegate: VDPlayerDelegate?
    
    var allowAutorotate: Bool = true {
        didSet {
            orientationObserver.allowAutorotate = allowAutorotate
        }
    }
    var isFullScreen: Bool { get { return orientationObserver.isFullScreen } }
    var fullScreenStateWillChange: ((VDPlayer, Bool) -> ())?
    var fullScreenStateDidChange: ((VDPlayer, Bool) -> ())?
    var playbackStateDidChanged: ((VDPlayer, VDPlayerPlaybackState) -> ())?
    var loadStateDidChanged: ((VDPlayer, VDPlayerLoadState) -> ())?
    lazy public var orientationObserver: VDPlayerOrientationObserver = {
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
    var currentTime: TimeInterval { get { return currentPlayerManager.currentTime } }
    var totalTime: TimeInterval { get { return currentPlayerManager.totalTime } }
    
    /// 播放器的容器
    var containerView: UIView? {
        didSet {
            guard let containerView = containerView else { return }
            containerView.addSubview(self.currentPlayerManager.view)
        }
    }
    
    /// 全屏容器
    var fullScreenContainerView: UIView? {
        get {
            return UIApplication.shared.keyWindow
        }
    }
    
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
    var gestureControl: VDPlayerGestureControl?
    
    /// 当前播放器内核
    var currentPlayerManager: VDPlayerPlayBackProtocol! {
        didSet {
            if oldValue?.isPreparedToPlay ?? false {
                oldValue?.stop()
                oldValue?.view.removeFromSuperview()
            }
            guard let currentPlayerControl = currentPlayerManager else { return }
            if let containerView = self.containerView {
//                containerView.insertSubview(currentPlayerControl.playerView, at: 1)
                containerView.addSubview(currentPlayerControl.view)
                currentPlayerControl.view.frame = containerView.bounds
                currentPlayerControl.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
                currentPlayerControl.playbackStateDidChanged = { player, state in
                    self.playbackStateDidChanged?(self, state)
                    self.controlView?.playerPlayStateChanged(player: self, playState: state)
                }
                currentPlayerControl.loadStateDidChanged = { player, state in
                    self.controlView?.playerLoadStateChanged(player: self, loadState: state)
                }
                currentPlayerControl.playerReadyToPlay = { player, assetURL in
                    do { try AVAudioSession.sharedInstance().setCategory(.playback, options: .allowBluetooth) } catch { }
                    do { try AVAudioSession.sharedInstance().setActive(true, options: []) } catch { }
                }
                currentPlayerControl.playerPrepareToPlay = { player, assetURL in
                    self.layoutPlayerSubViews()
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
            if autoPlayWhenPrepareToPlay {
                play()
            }
        }
    }
    
    /// 是否自动播放
    var autoPlayWhenPrepareToPlay: Bool = true
    
    deinit {
        currentPlayerManager.stop()
    }
    
    override private init() {
        super.init()
        let control = VDVLCPlayerManager()
        self.currentPlayerManager = control
    }
    
//    convenience init(config: VDPlayerConfig) {
//        self.init()
//    }
    
    @objc convenience init(playerControl: VDPlayerPlayBackProtocol, container: UIView) {
        self.init()
//        self.controlView = VDPlayerControlView()
        self.containerView = container
        self.currentPlayerManager = playerControl
        if let containerView = self.containerView {
            containerView.addSubview(self.currentPlayerManager.view)
//            containerView.insertSubview(self.currentPlayerControl.playerView, at: 1)
            currentPlayerManager.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            currentPlayerManager.playbackStateDidChanged = { [weak self] player, state in
                guard let weakSelf = self else { return }
                weakSelf.playbackStateDidChanged?(weakSelf, state)
                weakSelf.controlView?.playerPlayStateChanged(player: weakSelf, playState: state)
            }
            currentPlayerManager.loadStateDidChanged = { [weak self] player, state in
                guard let weakSelf = self else { return }
                weakSelf.controlView?.playerLoadStateChanged(player: weakSelf, loadState: state)
            }
            currentPlayerManager.playerPrepareToPlay = { [weak self] player, assetURL in
                guard let weakSelf = self else { return }
                weakSelf.layoutPlayerSubViews()
                weakSelf.controlView?.playerPrepareToPlay(player: weakSelf)
            }
            currentPlayerManager.mediaPlayerTimeChanged = { [weak self] player, currentTime, totalTime in
                guard let weakSelf = self else { return }
                guard let controlView = weakSelf.controlView else { return }
                controlView.updateTime(current: currentTime, total: totalTime)
            }
        }
    }
    
    private func layoutPlayerSubViews() {
        guard let controlView = controlView, let containerView = containerView else { return }
        
        controlView.removeFromSuperview()
        currentPlayerManager.view.addSubview(controlView)
        if isFullScreen {
            currentPlayerManager.view.frame = fullScreenContainerView?.bounds ?? .zero
        }
        else {
            currentPlayerManager.view.frame = containerView.bounds
        }

        controlView.frame = currentPlayerManager.view.bounds
        controlView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
//        orientationObserver.containerView = containerView
//        orientationObserver.playerView = currentPlayerManager.view
        orientationObserver.update(rotateView: currentPlayerManager.view, containerView: containerView)
        
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
        
        currentPlayerManager.assetURL = assetURLs[index]
    }
    
    func playNext() {
        
    }
    
    func playPrevious() {
        
    }
    
    @objc func pause() {
        currentPlayerManager.pause()
    }
    
    func fullScreenStateChange(animated: Bool) {
        let control = controlView as! VDPlayerControlView
        control.controlViewAppeared = false
        control.hideControlView(animated: true)
        
//        if isFullScreen {
//            orientationObserver.exitFullScreen(animate: true)
//        }
//        else {
//            orientationObserver.enterLandscapeFullScreen(orientation: .landscapeRight, animated: true)
//        }
//        if orientationObserver.fullScreenMode == .portrait {
//            orientationObserver.enterPortraitMode(fullScreen: isFullScreen, animated: animated, completion: nil)
//        }
//        else {
////            UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
////            orientation = fullScreen? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
////            [self.orientationObserver rotateToOrientation:orientation animated:animated completion:completion];
//            var orientation = UIInterfaceOrientation.unknown
//            orientation = isFullScreen ? .landscapeRight : .portrait
//            orientationObserver.rotate(to: orientation, animated: animated, completion: nil)
//        }
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
//            orientationObserver.enterLandscapeFullScreen(orientation: orientation, animated: animated, completion: completion)
            orientationObserver.rotate(to: orientation, animated: animated, completion: completion)
        }
    }
    
    func enterPortraitFullScreen(_ fullScreen: Bool, animated: Bool, completion:((_ completion: Bool)->())? = nil) {
        orientationObserver.fullScreenMode = .portrait
        orientationObserver.enterPortraitMode(fullScreen: fullScreen, animated: animated, completion: completion)
    }
}

// MARK: - OrientationObserverDelegate
extension VDPlayer: VDPlayerOrientationObserverDelegate {
    internal func orientationWillChange(observer: VDPlayerOrientationObserver, isFullScreen: Bool) {
        delegate?.playerOrientationWillChange(player: self, isFullScreen: isFullScreen)
        controlView?.playerOrientationWillChanged(player: self, observer: observer)
        fullScreenStateWillChange?(self, isFullScreen)
        controlView?.setNeedsLayout()
        controlView?.layoutIfNeeded()
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
        currentPlayerManager.seek(to: time, completionHandler: completionHandler)
    }
}
