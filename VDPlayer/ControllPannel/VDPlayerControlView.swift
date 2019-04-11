//
//  VDPlayerControlView.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019 vvard3n. All rights reserved.
//

import UIKit

class VDPlayerControlView: UIView, VDPlayerControlProtocol {
    var player: VDPlayer! {
        didSet {
            portraitControlView.player = self.player
            landScapeControlView.player = self.player
        }
    }
    /// 竖屏播放器控制面板
    private lazy var portraitControlView: VDPortraitControlView = {
        let portraitControlView = VDPortraitControlView()
        portraitControlView.sliderValueChanging = { (time, forward) in
            self.cancelAutoHiddenControlView()
        }
        portraitControlView.didEndSlidingProgressSlider = { (percent) in
            self.startAutoHiddenControlView()
        }
        return portraitControlView
    }()
    /// 横屏播放器控制面板
    private lazy var landScapeControlView: VDLandScapeControlView = {
        let landScapeControlView = VDLandScapeControlView()
        landScapeControlView.isHidden = true
        landScapeControlView.hideControlPanel()
        return landScapeControlView
    }()
    /// 控制面板显示状态
    var controlViewAppeared: Bool = true
    /// 底部进度条
    var bottomProgress: UIView = {
        let bottomProgress = UIView()
        return bottomProgress
    }()
    /// Loading视图
    var activity: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView()
        return activityView
    }()
    /// 展示控制面板后隐藏时间，default is 5
    var autoHiddenTimeInterval: TimeInterval = 5
    /// 隐藏和展示控制面板Fade动画的时间，default is 0.3
    var autoFadeAnimateTime: TimeInterval = 0.3
    private var autoHiddenWorkItem: DispatchWorkItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        addNotifications()
        
        startAutoHiddenControlView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(portraitControlView)
        addSubview(landScapeControlView)
        addSubview(activity)
//        addSubview(bottomProgress)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = 0
        var h: CGFloat = 0
        let maxHeight = bounds.height
        let maxWidth = bounds.width
        
        portraitControlView.frame = self.bounds;
        landScapeControlView.frame = self.bounds;
        
        x = 0
        y = maxHeight - 2
        w = maxWidth
        h = 2
        bottomProgress.frame = CGRect(x: x, y: y, width: w, height: h)
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(systemVolumeChanged(noti:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        cancelAutoHiddenControlView()
    }
    
    func showControlView(animated: Bool) {
        controlViewAppeared = true
        startAutoHiddenControlView()
        if animated {
            UIView.animate(withDuration: autoFadeAnimateTime, animations: {
                if self.player.isFullScreen {
                    self.landScapeControlView.showControlPanel()
                }
                else {
                    self.portraitControlView.showControlPanel()
                }
            }) { (finished) in
                self.bottomProgress.isHidden = true
            }
        }
        else {
            if self.player.isFullScreen {
                self.landScapeControlView.showControlPanel()
            }
            else {
                self.portraitControlView.showControlPanel()
            }
            self.bottomProgress.isHidden = true
        }
    }
    
    func hideControlView(animated: Bool) {
        controlViewAppeared = false
        if animated {
            UIView.animate(withDuration: autoFadeAnimateTime, animations: {
                if self.player.isFullScreen {
                    self.landScapeControlView.hideControlPanel()
                }
                else {
                    self.portraitControlView.hideControlPanel()
                }
            }) { (finished) in
                self.bottomProgress.isHidden = false
            }
        }
        else {
            if self.player.isFullScreen {
                self.landScapeControlView.hideControlPanel()
            }
            else {
                self.portraitControlView.hideControlPanel()
            }
            self.bottomProgress.isHidden = false
        }
    }
    
    func startAutoHiddenControlView() {
        cancelAutoHiddenControlView()
        
        autoHiddenWorkItem = DispatchWorkItem {
            self.hideControlView(animated: true)
        }
        guard let autoHiddenWorkItem = autoHiddenWorkItem else { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + autoHiddenTimeInterval, execute: autoHiddenWorkItem)
    }
    
    func cancelAutoHiddenControlView() {
        if let autoHiddenWorkItem = autoHiddenWorkItem {
            autoHiddenWorkItem.cancel()
            self.autoHiddenWorkItem = nil
        }
    }
    
    func reset() {
        portraitControlView.reset()
        landScapeControlView.reset()
    }
}

// MARK: - Time
extension VDPlayerControlView {
    func updateTime(current: TimeInterval, total: TimeInterval) {
        portraitControlView.updateTime(current: current, total: total)
    }
}

// MARK: - Private Methon
extension VDPlayerControlView {
    @objc private func systemVolumeChanged(noti: Notification) {
        
    }
}

// MARK: - Protocol
extension VDPlayerControlView {
    internal func gestureSingleTapped() {
//        guard let player == player else { return }
        if player == nil { return }
        if controlViewAppeared {
            hideControlView(animated: true)
            controlViewAppeared = false
        }
        else {
            hideControlView(animated: false)
            showControlView(animated: true)
            controlViewAppeared = true
        }
    }
    
    internal func gestureDoubleTapped() {
        if player == nil { return }
        if player.currentPlayerControl.isPlaying {
            player.currentPlayerControl.pause()
        }
        else {
            player.currentPlayerControl.play()
        }
    }
    
    internal func gesturePan(panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .began {
            
        }
        switch panGesture.state {
        case .began:
            break
        case .changed:
            print(panGesture.location(in: self))
        default:
            break
        }
    }
    
    internal func playerOrientationWillChanged(player: VDPlayer, observer: VDPlayerOrientationObserver) {
        portraitControlView.isHidden = player.isFullScreen;
        landScapeControlView.isHidden = !player.isFullScreen;
    }
    
    internal func playerOrientationDidChanged(player: VDPlayer, observer: VDPlayerOrientationObserver) {
        
    }
}
