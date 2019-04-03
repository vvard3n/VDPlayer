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
    var portraitControlView: VDPortraitControlView = VDPortraitControlView()
    /// 横屏播放器控制面板
    var landScapeControlView: VDLandScapeControlView = VDLandScapeControlView()
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
    /// 展示控制面板后隐藏时间，default is 3
    var autoHiddenTimeInterval: TimeInterval = 3
    /// 隐藏和展示控制面板Fade动画的时间，default is 0.2
    var autoFadeAnimateTime: TimeInterval = 0.2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        addNotifications()
        
//        portraitControlView.isHidden = player.isFullScreen;
//        landScapeControlView.isHidden = !player.isFullScreen;
        landScapeControlView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(portraitControlView)
        addSubview(landScapeControlView)
        addSubview(activity)
        addSubview(bottomProgress)
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
    }
    
    func showControlView(animated: Bool) {
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
    
    func hideControlView(animated: Bool) {
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
    
    func reset() {
        
    }
}


// MARK: - Private Methon
extension VDPlayerControlView {
    @objc private func systemVolumeChanged(noti: Notification) {
        
    }
}
