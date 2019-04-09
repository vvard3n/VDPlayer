//
//  VDLandScapeControlView.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class VDLandScapeControlView: UIView {
    
    weak var player: VDPlayer!
    
    /// 顶部View
    var topView: UIView = {
        let topView = UIView()
        topView.backgroundColor = .random
        return topView
    }()
    
    /// 返回按钮
    var backBtn: UIButton = {
        let backBtn = UIButton(type: .custom)
        backBtn.backgroundColor = .random
        return backBtn
    }()
    
    /// 标题栏
    var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.backgroundColor = .random
        return titleLabel
    }()
    
    /// 底部View
    var bottomView: UIView = {
        let bottomView = UIView()
        bottomView.backgroundColor = .random
        return bottomView
    }()
    
    /// 播放暂停按钮
    var playPauseBtn: UIButton = {
        let playPauseBtn = UIButton()
        playPauseBtn.backgroundColor = .random
        return playPauseBtn
    }()
    
    /// 可拖动进度条
    var progressSlider: UISlider = {
        let progressSlider = UISlider()
        progressSlider.backgroundColor = .random
        return progressSlider
    }()
    
    /// 全屏按钮
    var fullScreenBtn: UIButton = {
        let fullScreenBtn = UIButton()
        fullScreenBtn.backgroundColor = .random
        fullScreenBtn.setTitle("回", for: .normal)
        fullScreenBtn.setTitleColor(.white, for: .normal)
        return fullScreenBtn
    }()
    
    /// 隐藏控制面板的进度条
    var progressView: UIView = {
        let progressSlider = UIView()
        progressSlider.backgroundColor = .random
        return progressSlider
    }()
    
    /// 当前播放时间
    var currentTimeLabel: UILabel = {
        let currentTimeLabel = UILabel()
        currentTimeLabel.backgroundColor = .random
        return currentTimeLabel
    }()
    
    /// 媒体总时长
    var totalTimeLabel: UILabel = {
        let totalTimeLabel = UILabel()
        totalTimeLabel.backgroundColor = .random
        return totalTimeLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(topView)
        topView.addSubview(backBtn)
        topView.addSubview(titleLabel)
        
        addSubview(bottomView)
        bottomView.addSubview(playPauseBtn)
        bottomView.addSubview(currentTimeLabel)
        bottomView.addSubview(fullScreenBtn)
        bottomView.addSubview(progressSlider)
        bottomView.addSubview(totalTimeLabel)
        
        addSubview(progressView)
        
        addSubviewActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviewActions() {
        playPauseBtn.addTarget(self, action: #selector(playPauseBtnDidClick(_:)), for: .touchUpInside)
        fullScreenBtn.addTarget(self, action: #selector(fullScreenBtnDidClick(_:)), for: .touchUpInside)
    }
    
    let kTopViewHeight: CGFloat = 80
    let kBottomViewHeight: CGFloat = 73
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maxWidth = bounds.size.width
        let maxHeight = bounds.size.height
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = 0
        var h: CGFloat = 0
        
        x = 0
        y = 0
        w = maxWidth
        h = kTopViewHeight + SAFE_AREA_TOP
        topView.frame = CGRect(x: x, y: y, width: w, height: h)
        
        x = VDUIManager.shared().safeAreaInset.top
        y = 15
        w = 44
        h = w
        backBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        
        x = backBtn.frame.maxX + 5
        y = 15
        w = maxWidth - x - 15
        h = 30
        titleLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        
        x = 0
        y = maxHeight - kBottomViewHeight
        w = maxWidth
        h = kBottomViewHeight + SAFE_AREA_BOTTOM
        bottomView.frame = CGRect(x: x, y: y, width: w, height: h)
        
        x = VDUIManager.shared().safeAreaInset.top
        w = 50
        h = 50
        y = (kBottomViewHeight - h) / 2
        playPauseBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        
        x = playPauseBtn.frame.maxX + 5
        w = 62
        h = 28
        y = 0
        currentTimeLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        currentTimeLabel.center.y = playPauseBtn.center.y
        
        w = 44
        h = w
        x = maxWidth - SAFE_AREA_BOTTOM - 10 - w
        y = 0
        fullScreenBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        fullScreenBtn.center.y = playPauseBtn.center.y
        
        w = 62
        x = fullScreenBtn.frame.minX - 5 - w
        h = 28
        y = 0
        totalTimeLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        totalTimeLabel.center.y = playPauseBtn.center.y
        
        x = currentTimeLabel.frame.maxX + 5
        y = 0
        w = totalTimeLabel.frame.minX - 5 - x
        h = 30
        progressSlider.frame = CGRect(x: x, y: y, width: w, height: h)
        progressSlider.center.y = playPauseBtn.center.y
        
//        x = 0
//        y = maxHeight - 2
//        w = maxWidth
//        h = 2
//        bottomProgressView.frame = CGRect(x: x, y: y, width: w, height: h)
    }
}

// MARK: - Actions
extension VDLandScapeControlView {
    @objc private func playPauseBtnDidClick(_ sender: UIButton) {
        self.playPauseBtn.isSelected = !self.playPauseBtn.isSelected
    }
    
    @objc private func fullScreenBtnDidClick(_ sender: UIButton) {
        player.fullScreenStateChange(animated: true)
    }
}

extension VDLandScapeControlView {
    func showControlPanel(){
        self.topView.alpha = 1
        self.bottomView.alpha = 1
    }
    
    func hideControlPanel(){
        self.topView.alpha = 0
        self.bottomView.alpha = 0
    }
}
