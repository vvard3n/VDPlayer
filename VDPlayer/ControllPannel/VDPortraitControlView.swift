//
//  VDPortraitControlView.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019 vvard3n. All rights reserved.
//

import UIKit

class VDPortraitControlView: UIView {

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
        playPauseBtn.setImage(UIImage(vd_named: "play_red"), for: .normal)
        playPauseBtn.setImage(UIImage(vd_named: "pause_red"), for: .selected)
        playPauseBtn.adjustsImageWhenHighlighted = false
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
        return fullScreenBtn
    }()
    
    /// 隐藏控制面板的进度条
    var bottomProgressView: UIView = {
        let bottomProgressView = UIView()
        bottomProgressView.backgroundColor = .random
        return bottomProgressView
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
        bottomView.addSubview(currentTimeLabel)
        bottomView.addSubview(progressSlider)
        bottomView.addSubview(totalTimeLabel)
        bottomView.addSubview(fullScreenBtn)
        
        addSubview(bottomProgressView)
        addSubview(playPauseBtn)
        
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
        h = kTopViewHeight
        topView.frame = CGRect(x: x, y: y, width: w, height: h)
        
        x = 15
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
        h = kBottomViewHeight
        bottomView.frame = CGRect(x: x, y: y, width: w, height: h)
        
        x = 10
        w = 62
        h = 28
        y = (kBottomViewHeight - h) / 2
        currentTimeLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        
        w = 44
        h = w
        x = maxWidth - 10 - w
        y = 0
        fullScreenBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        fullScreenBtn.center.y = currentTimeLabel.center.y
        
        w = 62
        x = fullScreenBtn.frame.minX - 5 - w
        h = 28
        y = (kBottomViewHeight - h) / 2
        totalTimeLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        totalTimeLabel.center.y = currentTimeLabel.center.y
        
        x = currentTimeLabel.frame.maxX + 5
        y = 0
        w = totalTimeLabel.frame.minX - 5 - x
        h = 30
        progressSlider.frame = CGRect(x: x, y: y, width: w, height: h)
        progressSlider.center.y = currentTimeLabel.center.y
        
        x = 0
        y = maxHeight - 2
        w = maxWidth
        h = 2
        bottomProgressView.frame = CGRect(x: x, y: y, width: w, height: h)
        
        x = 0
        y = 0
        w = 50
        h = w
        playPauseBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        playPauseBtn.center = center
//        playPauseBtn.translatesAutoresizingMaskIntoConstraints = false
//        addConstraints([NSLayoutConstraint(item: playPauseBtn,
//                                           attribute: .centerX,
//                                           relatedBy: .equal,
//                                           toItem: self,
//                                           attribute: .centerX,
//                                           multiplier: 1.0,
//                                           constant: 0),
//                        NSLayoutConstraint(item: playPauseBtn,
//                                           attribute: .width,
//                                           relatedBy: .equal,
//                                           toItem: nil,
//                                           attribute: .notAnAttribute,
//                                           multiplier: 1,
//                                           constant: 50),
//                        NSLayoutConstraint(item: playPauseBtn,
//                                           attribute: .centerY,
//                                           relatedBy: .equal,
//                                           toItem: self,
//                                           attribute: .centerY,
//                                           multiplier: 1.0,
//                                           constant: 0),
//                        NSLayoutConstraint(item: playPauseBtn,
//                                           attribute: .height,
//                                           relatedBy: .equal,
//                                           toItem: playPauseBtn,
//                                           attribute: .width,
//                                           multiplier: 1,
//                                           constant: 0)])
    }
}

// MARK: - Actions
extension VDPortraitControlView {
    @objc private func playPauseBtnDidClick(_ sender: UIButton) {
        self.playPauseBtn.isSelected = !self.playPauseBtn.isSelected
    }
    
    @objc private func fullScreenBtnDidClick(_ sender: UIButton) {
        player.fullScreenStateChange(animated: true)
    }
}
    
extension VDPortraitControlView {
    func showControlPanel(){
        UIView.animate(withDuration: 0.5, animations: {
            self.topView.alpha = 1
            self.bottomView.alpha = 1
            self.bottomProgressView.alpha = 0
            self.playPauseBtn.alpha = 1
        }) { (complate) in
            
        }
    }
    
    func hideControlPanel(){
        UIView.animate(withDuration: 0.5, animations: {
            self.topView.alpha = 0
            self.bottomView.alpha = 0
            self.bottomProgressView.alpha = 1
            self.playPauseBtn.alpha = 0
        }) { (complate) in
            
        }
    }
}
