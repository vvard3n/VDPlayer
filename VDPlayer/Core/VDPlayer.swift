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
            layoutPlayer()
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
                currentPlayerControl.playerReadyToPlay = { player, assetURL in
                    do { try AVAudioSession.sharedInstance().setCategory(.playback, options: .allowBluetooth) } catch { }
                    do { try AVAudioSession.sharedInstance().setActive(true, options: []) } catch { }
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
            if autoPlayWhenPrepareToPlay {
                play()
            }
        }
    }
    
    /// 是否自动播放
    var autoPlayWhenPrepareToPlay: Bool = true
    
    deinit {
        currentPlayerControl.stop()
    }
    
    override private init() {
        super.init()
        let control = VDVLCPlayerControl()
        self.currentPlayerControl = control
    }
    
//    convenience init(config: VDPlayerConfig) {
//        self.init()
//    }
    
    @objc convenience init(playerControl: VDPlayerPlayBackProtocol, container: UIView) {
        self.init()
//        self.controlView = VDPlayerControlView()
        self.containerView = container
        self.currentPlayerControl = playerControl
        if let containerView = self.containerView {
            containerView.addSubview(self.currentPlayerControl.playerView)
//            containerView.insertSubview(self.currentPlayerControl.playerView, at: 1)
            currentPlayerControl.playerView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            currentPlayerControl.playbackStateDidChanged = { [weak self] player, state in
                guard let weakSelf = self else { return }
                weakSelf.playbackStateDidChanged?(weakSelf, state)
                weakSelf.controlView?.playerPlayStateChanged(player: weakSelf, playState: state)
            }
            currentPlayerControl.loadStateDidChanged = { [weak self] player, state in
                guard let weakSelf = self else { return }
                weakSelf.controlView?.playerLoadStateChanged(player: weakSelf, loadState: state)
            }
            currentPlayerControl.playerPrepareToPlay = { [weak self] player, assetURL in
                guard let weakSelf = self else { return }
                weakSelf.layoutPlayer()
                weakSelf.controlView?.playerPrepareToPlay(player: weakSelf)
            }
            currentPlayerControl.mediaPlayerTimeChanged = { [weak self] player, currentTime, totalTime in
                guard let weakSelf = self else { return }
                guard let controlView = weakSelf.controlView else { return }
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
        
        orientationObserver.containerView = containerView
        orientationObserver.playerView = currentPlayerControl.playerView
        
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
    
    @objc func pause() {
        currentPlayerControl.pause()
    }
    
    func fullScreenStateChange(animated: Bool) {
        let control = controlView as! VDPlayerControlView
        control.controlViewAppeared = false
        control.hideControlView(animated: true)
        
        if isFullScreen {
            orientationObserver.exitFullScreen(animate: true)
        }
        else {
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
