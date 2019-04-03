//
//  VDLandScapeControlView.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class VDLandScapeControlView: UIView, VDPlayerControlProtocol {
    
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
        bottomView.addSubview(progressSlider)
        bottomView.addSubview(totalTimeLabel)
        
        addSubview(progressView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        x = player.isFullScreen ? SAFE_AREA_LEFT + 15 : 15
        y = player.isFullScreen ? SAFE_AREA_TOP + 20 : 15
        w = 44
        h = 44
        backBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        
        x = backBtn.frame.maxX + 5
        y = (backBtn.bounds.maxY - 30) / 2
        w = maxWidth - x - 15
        h = 30
        titleLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        
        x = 0
        y = maxHeight - (kBottomViewHeight + SAFE_AREA_BOTTOM)
        w = maxWidth
        h = kBottomViewHeight + SAFE_AREA_BOTTOM
        bottomView.frame = CGRect(x: x, y: y, width: w, height: h)
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
