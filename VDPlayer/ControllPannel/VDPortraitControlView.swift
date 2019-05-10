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
    private var progressSliderIsDragging: Bool = false
    var sliderValueChanging: ((_ percent: Float, _ forward: Bool) -> ())?
    var didEndSlidingProgressSlider: ((_ percent: Float) -> ())?
    
    private var startTouchMovePoint :CGPoint = .zero
    private var allowPanGesture: Bool = false
    private var sliderStartValue: Float = 0
    
    /// 顶部View
    var topView: UIView = {
        let topView = UIView()
        
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.colors = [UIColor(white: 0, alpha: 1).cgColor, UIColor.clear.cgColor]
        layer.locations = [0.0, 1.0]
        layer.shouldRasterize = true
        topView.layer.addSublayer(layer)
        
        return topView
    }()
    
    /// 返回按钮
    var backBtn: UIButton = {
        let backBtn = UIButton(type: .custom)
//        backBtn.backgroundColor = .random
        backBtn.setImage(UIImage(vd_named: "back_36x36_fff@2x"), for: .normal)
        return backBtn
    }()
    
    /// 标题栏
    var titleLabel: UILabel = {
        let titleLabel = UILabel()
//        titleLabel.backgroundColor = .random
        titleLabel.text = "标题标题标题标题标题标题标题标题"
        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.textColor = .white
        return titleLabel
    }()
    
    /// 底部View
    var bottomView: UIView = {
        let bottomView = UIView()

        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.colors = [UIColor.clear.cgColor, UIColor(white: 0, alpha: 1).cgColor]
        layer.locations = [0.0, 1.0]
        layer.shouldRasterize = true
        bottomView.layer.addSublayer(layer)
        
        return bottomView
    }()
    
    /// 播放暂停按钮
    var playPauseBtn: UIButton = {
        let playPauseBtn = UIButton()
        playPauseBtn.setImage(UIImage(vd_named: "play"), for: .normal)
        playPauseBtn.setImage(UIImage(vd_named: "pause"), for: .selected)
        playPauseBtn.adjustsImageWhenHighlighted = false
        playPauseBtn.isSelected = true
        return playPauseBtn
    }()
    
    /// 可拖动进度条
    var progressSlider: UISlider = {
        let progressSlider = UISlider()
//        progressSlider.backgroundColor = .random
        progressSlider.tintColor = UIColor(hex: "E63130")
        progressSlider.setThumbImage(UIImage(vd_named: "slider_point"), for: .normal)
        return progressSlider
    }()
    
    /// 全屏按钮
    var fullScreenBtn: UIButton = {
        let fullScreenBtn = UIButton()
        fullScreenBtn.setImage(UIImage(vd_named: "fullscreen"), for: .normal)
        fullScreenBtn.imageView?.contentMode = .scaleAspectFill
        return fullScreenBtn
    }()
    
    /// 隐藏控制面板的进度条
    var bottomProgressView: UIView = {
        let bottomProgressView = UIView()
        bottomProgressView.backgroundColor = UIColor(hex: "E63130")
        bottomProgressView.alpha = 0
        return bottomProgressView
    }()
    
    /// 当前播放时间
    var currentTimeLabel: UILabel = {
        let currentTimeLabel = UILabel()
//        currentTimeLabel.backgroundColor = .random
        currentTimeLabel.font = .systemFont(ofSize: 10)
        currentTimeLabel.textAlignment = .center
        currentTimeLabel.textColor = .white
        return currentTimeLabel
    }()
    
    /// 媒体总时长
    var totalTimeLabel: UILabel = {
        let totalTimeLabel = UILabel()
//        totalTimeLabel.backgroundColor = .random
        totalTimeLabel.font = .systemFont(ofSize: 10)
        totalTimeLabel.textAlignment = .center
        totalTimeLabel.textColor = .white
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
        
        bottomProgressView.frame = CGRect(x: 0, y: bounds.height - 2, width: 0, height: 2)
        
        addSubview(playPauseBtn)
        
        addSubviewActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviewActions() {
        playPauseBtn.addTarget(self, action: #selector(playPauseBtnDidClick(_:)), for: .touchUpInside)
        fullScreenBtn.addTarget(self, action: #selector(fullScreenBtnDidClick(_:)), for: .touchUpInside)
        
        progressSlider.addTarget(self, action: #selector(didSliderTouchDown(_:)), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(didSliderTouchCancel(_:)), for: .touchCancel)
        progressSlider.addTarget(self, action: #selector(didSliderTouchUpOutside(_:)), for: .touchUpOutside)
        progressSlider.addTarget(self, action: #selector(didSliderTouchUpInside(_:)), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(didSliderValueChanged(_:)), for: .valueChanged)
    }
    
    private let kTopViewHeight: CGFloat = 80
    private let kBottomViewHeight: CGFloat = 73
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
        topView.layer.sublayers?.first?.frame = topView.bounds
        
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
        bottomView.layer.sublayers?.first?.frame = bottomView.bounds
        
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
        y = 0
        w = 50
        h = w
        playPauseBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        playPauseBtn.center = center
        
        bottomProgressView.frame.origin.x = 0
        bottomProgressView.frame.origin.y = maxHeight - 2
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
    
    func reset() {
        playPauseBtn.isSelected = false
        currentTimeLabel.text = "00:00:00"
        totalTimeLabel.text = "00:00:00"
        progressSlider.value = 0
        progressSlider.maximumValue = 0
        bottomProgressView.frame.size.width = 0
    }
}

// MARK: - Actions
extension VDPortraitControlView {
    @objc private func playPauseBtnDidClick(_ sender: UIButton) {
        self.playPauseBtn.isSelected = !self.playPauseBtn.isSelected
        if playPauseBtn.isSelected {
            player.currentPlayerControl.play()
        }
        else {
            player.currentPlayerControl.pause()
        }
    }
    
    @objc private func fullScreenBtnDidClick(_ sender: UIButton) {
        player.fullScreenStateChange(animated: true)
    }
    
    @objc private func didSliderTouchDown(_ sender: UISlider) {
        progressSliderIsDragging = true
        
        sliderStartValue = sender.value
    }
    
    @objc private func didSliderTouchCancel(_ sender: UISlider) {
        progressSliderIsDragging = false
        
        sliderStartValue = 0
    }
    
    @objc private func didSliderTouchUpOutside(_ sender: UISlider) {
        let percent = sender.value / sender.maximumValue
        player.seek(to: player.totalTime * Double(percent)) { (success) in
            if success {
                self.progressSliderIsDragging = false
            }
        }
        if let didEndSlidingProgressSlider = didEndSlidingProgressSlider { didEndSlidingProgressSlider(percent) }
    }
    
    @objc private func didSliderTouchUpInside(_ sender: UISlider) {
        sliderStartValue = 0
        let percent = sender.value / sender.maximumValue
        player.seek(to: player.totalTime * Double(percent)) { (success) in
            if success {
                self.progressSliderIsDragging = false
            }
        }
        if let didEndSlidingProgressSlider = didEndSlidingProgressSlider { didEndSlidingProgressSlider(percent) }
    }
    
    @objc private func didSliderValueChanged(_ sender: UISlider) {
        let forward = sliderStartValue < sender.value
        print(forward)
        sliderStartValue = sender.value
        let current = Double(progressSlider.value)
        let total = player.totalTime
        currentTimeLabel.text = vd_formateTime(current, customFormateStr: nil)
        totalTimeLabel.text = vd_formateTime(total, customFormateStr: nil)
        
        let percent = sender.value / sender.maximumValue
        if let sliderValueChanging = sliderValueChanging { sliderValueChanging(percent, forward) }
        
        UIView.animate(withDuration: 0.25) {
            self.bottomProgressView.frame = CGRect(x: 0, y: self.bounds.height - 2, width: self.bounds.width * CGFloat(current / total), height: 2)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let point = touches.first?.location(in: self) ?? .zero
        if point.y < 100 || point.y > SCREEN_HEIGHT - 100 {
            print("超出滑动区域")
            allowPanGesture = false
        }
        else {
            allowPanGesture = true
            progressSliderIsDragging = true
            startTouchMovePoint = point
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if !allowPanGesture { return }
        let point = touches.first?.location(in: self) ?? .zero
        let progressInSec: Float = 2
        if abs(point.x - startTouchMovePoint.x) > 10 {
            if point.x > startTouchMovePoint.x {
                var current = Double(progressSlider.value + progressInSec)
                print(current)
                let total = player.totalTime
                if current > total { current = total }
                currentTimeLabel.text = vd_formateTime(current, customFormateStr: nil)
                totalTimeLabel.text = vd_formateTime(total, customFormateStr: nil)
                progressSlider.value = Float(current)
                
                if let sliderValueChanging = sliderValueChanging { sliderValueChanging(Float(current / total), true) }
                
                UIView.animate(withDuration: 0.25) {
                    self.bottomProgressView.frame = CGRect(x: 0, y: self.bounds.height - 2, width: self.bounds.width * CGFloat(current / total), height: 2)
                }
            }
            else {
                var current = Double(progressSlider.value - progressInSec)
                if current < 0 { current = 0 }
                print(current)
                let total = player.totalTime
                currentTimeLabel.text = vd_formateTime(current, customFormateStr: nil)
                totalTimeLabel.text = vd_formateTime(total, customFormateStr: nil)
                progressSlider.value = Float(current)
                
                if let sliderValueChanging = sliderValueChanging { sliderValueChanging(Float(current / total), true) }
                
                UIView.animate(withDuration: 0.25) {
                    self.bottomProgressView.frame = CGRect(x: 0, y: self.bounds.height - 2, width: self.bounds.width * CGFloat(current / total), height: 2)
                }
            }
            startTouchMovePoint = point
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        allowPanGesture = false
        progressSliderIsDragging = false
        
        let seekTime = TimeInterval(progressSlider.value)
        let percent = progressSlider.value / progressSlider.maximumValue
        player.seek(to: seekTime) { (success) in
            if success {
                self.progressSliderIsDragging = false
            }
        }
        if let didEndSlidingProgressSlider = didEndSlidingProgressSlider { didEndSlidingProgressSlider(percent) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        allowPanGesture = false
        progressSliderIsDragging = false
    }
}

extension VDPortraitControlView {
    func updateTime(current: TimeInterval, total: TimeInterval) {
        if !progressSliderIsDragging {
            currentTimeLabel.text = vd_formateTime(current, customFormateStr: nil)
            totalTimeLabel.text = vd_formateTime(total, customFormateStr: nil)
//            print("playback current time:\(player.currentTime)s")
            progressSlider.value = Float(player.currentTime ?? 0)
            progressSlider.maximumValue = Float(player.totalTime)
            UIView.animate(withDuration: 0.25) {
                self.bottomProgressView.frame = CGRect(x: 0, y: self.bounds.height - 2, width: self.bounds.width * CGFloat(current / total), height: 2)
            }
        }
    }
}
    
extension VDPortraitControlView {
    func showControlPanel(){
        self.topView.alpha = 1
        self.bottomView.alpha = 1
        self.bottomProgressView.alpha = 0
        self.playPauseBtn.alpha = 1
    }
    
    func hideControlPanel(){
        self.topView.alpha = 0
        self.bottomView.alpha = 0
        self.bottomProgressView.alpha = 1
        self.playPauseBtn.alpha = 0
    }
}
