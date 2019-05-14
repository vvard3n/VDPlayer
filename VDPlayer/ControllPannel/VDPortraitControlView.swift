//
//  VDPortraitControlView.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019 vvard3n. All rights reserved.
//

import UIKit
import MediaPlayer

enum VDPortraitGestureType {
    case none
    case progress
    case rate
    case volume
    case light
}

class VDPortraitControlView: UIView {
    
    lazy var volumeView: MPVolumeView = {
        let volumeView = MPVolumeView(frame: CGRect(x: 0, y: -100, width: 320, height: 100))
        if let superview = self.superview {
            superview.addSubview(volumeView)
        }
        return volumeView
    }()

    weak var player: VDPlayer!
    private var progressSliderIsDragging: Bool = false
    var sliderValueChanging: ((_ percent: Float, _ forward: Bool) -> ())?
    var didEndSlidingProgressSlider: ((_ percent: Float) -> ())?
    var backBtnClickCallback: (() -> ())? {
        didSet {
            layoutSubviews()
        }
    }
    
    private var startTouchMovePoint: CGPoint = .zero
    private var progressPoint: CGPoint = .zero
    
    private var allowPanGesture: Bool = false
    private var allowChangeGestureType: Bool = true
    private var sliderStartValue: Float = 0
    private var controlPanelIsAppear: Bool = false
    private var currentGestureType: VDPortraitGestureType = .none
    
    /// 顶部View
    var topView: UIView = {
        let topView = UIView()
        
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.colors = [UIColor(white: 0, alpha: 0.8).cgColor, UIColor.clear.cgColor]
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
        layer.colors = [UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.8).cgColor]
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
        fullScreenBtn.setImage(UIImage(vd_named: "fullscreen_enter"), for: .normal)
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
        bottomView.addSubview(playPauseBtn)
        
        addSubview(bottomProgressView)
        
        bottomProgressView.frame = CGRect(x: 0, y: bounds.height - 2, width: 0, height: 2)
        
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
    
    private let kTopViewHeight: CGFloat = 50
    private let kBottomViewHeight: CGFloat = 50
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
        backBtn.isHidden = backBtnClickCallback == nil
        
        x = (backBtnClickCallback == nil ? 15 : backBtn.frame.maxX) + 5
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
        
        x = 0
        y = 0
        w = 50
        h = w
        playPauseBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        
        x = playPauseBtn.frame.maxX
        w = 62
        h = 28
        y = (kBottomViewHeight - h) / 2
        currentTimeLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        
        w = 44
        h = w
        x = maxWidth - w
        y = 0
        fullScreenBtn.frame = CGRect(x: x, y: y, width: w, height: h)
        fullScreenBtn.center.y = currentTimeLabel.center.y
        
        w = 62
        x = fullScreenBtn.frame.minX - w
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
        let point = touches.first?.location(in: self) ?? .zero
        if (point.y < 50 || point.y > bounds.height - 50) && controlPanelIsAppear {
//            super.touchesBegan(touches, with: event)
            allowPanGesture = false
            currentGestureType = .none
        }
        else {
            startTouchMovePoint = point
            if event?.allTouches?.count == 2 {
                print("双指滑动开始")
//                allowPanGesture = false
//                progressSliderIsDragging = false
//                currentGestureType = .rate
            }
            if event?.allTouches?.count == 1 {
//                progressPoint = point
//                allowPanGesture = true
//                progressSliderIsDragging = true
//                currentGestureType = .progress
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesMoved(touches, with: event)
        let point = touches.first?.location(in: self) ?? .zero
        if abs(point.x - startTouchMovePoint.x) <= 30 && abs(point.y - startTouchMovePoint.y) <= 20 && allowChangeGestureType {
            print("current use \(event?.allTouches?.count ?? 0) points")
            allowPanGesture = false
            progressSliderIsDragging = false
            
            let moveX = abs(point.x - startTouchMovePoint.x)
            let moveY = abs(point.y - startTouchMovePoint.y)
            print("moveX \(moveX) moveY \(moveY)")
            
            let pointCount = event?.allTouches?.count ?? 0
            if pointCount == 2 {
                currentGestureType = .rate
            }
            if pointCount == 1 {
                progressPoint = point
                if moveX >= moveY {
                    allowPanGesture = true
                    progressSliderIsDragging = true
                    currentGestureType = .progress
                }
                else {
                    if startTouchMovePoint.x <= bounds.size.width * 0.5 {
                        currentGestureType = .light
                    }
                    else {
                        currentGestureType = .volume
                    }
                }
            }
            return
        }
        
        allowChangeGestureType = false
        if currentGestureType == .light {
            print("light changing")
            if abs(point.y - progressPoint.y) > bounds.size.height / 100.0 {
                print(bounds.size.height / 100.0 / 100.0)
                print("current screen light \(UIScreen.main.brightness)")
                if point.y < progressPoint.y {
                    UIScreen.main.brightness += bounds.size.height / 100.0 / 100.0 * 2
                }
                else {
                    UIScreen.main.brightness -= bounds.size.height / 100.0 / 100.0 * 2
                }
                guard let superview = self.superview else { return }
                VDHUDLabel.show(text: String(format: "亮度%d%%", Int(UIScreen.main.brightness * 100)), in: superview)
                
                progressPoint = point
            }
        }
        if currentGestureType == .volume {
            print("volume changing")
//            let volumeView = MPVolumeView(frame: CGRect(x: 0, y: 100, width: 320, height: 100))
//            volumeView.isHidden = true
            
            var slider: UISlider? = nil
            for subview in volumeView.subviews {
                if subview.isKind(of: UISlider.self) {
                    slider = subview as? UISlider
                    break
                }
            }
            if abs(point.y - progressPoint.y) > bounds.size.height / 100.0 {
                let changeValue: Float = Float(bounds.size.height) / 100.0 / 100.0 * 2
                if point.y < progressPoint.y {
                    slider?.setValue((slider?.value ?? 0) + changeValue, animated: false)
                }
                else {
                    slider?.setValue((slider?.value ?? 0) - changeValue, animated: false)
                }
                slider?.sendActions(for: .touchUpInside)
                
                guard let superview = self.superview else { return }
                VDHUDLabel.show(text: String(format: "音量%d%%", Int((slider?.value ?? 0) * 100)), in: superview)
                
                progressPoint = point
            }
        }
        if currentGestureType == .rate {
            print("rate changing")
        }
        if currentGestureType == .progress {
            print("progress changing")
            if !allowPanGesture { return }
            let progressInSec: Float = 2
            if abs(point.x - progressPoint.x) > 5 {
                if point.x > progressPoint.x {
                    var current = Double(progressSlider.value + progressInSec)
                    print(current)
                    let total = player.totalTime
                    if current > total { current = total }
                    currentTimeLabel.text = vd_formateTime(current, customFormateStr: nil)
                    totalTimeLabel.text = vd_formateTime(total, customFormateStr: nil)
                    progressSlider.value = Float(current)
                    
                    if let sliderValueChanging = sliderValueChanging { sliderValueChanging(Float(current / total), true) }
                    
                    guard let superview = self.superview else { return }
                    VDHUDLabel.show(text: "\(vd_formateTime(current, customFormateStr: nil))/\(vd_formateTime(player.totalTime, customFormateStr: nil))", in: superview)
                    
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
                    
                    guard let superview = self.superview else { return }
                    VDHUDLabel.show(text: "\(vd_formateTime(current, customFormateStr: nil))/\(vd_formateTime(player.totalTime, customFormateStr: nil))", in: superview)
                    
                    UIView.animate(withDuration: 0.25) {
                        self.bottomProgressView.frame = CGRect(x: 0, y: self.bounds.height - 2, width: self.bounds.width * CGFloat(current / total), height: 2)
                    }
                }
                progressPoint = point
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGestureType == .none {
//            super.touchesEnded(touches, with: event)
        }
        if currentGestureType == .volume {
            VDHUDLabel.hide()
        }
        if currentGestureType == .light {
            VDHUDLabel.hide()
        }
        if currentGestureType == .rate {
            let point = touches.first?.location(in: self) ?? .zero
            let currentRate = player.currentPlayerControl.rate
            var targetRate = currentRate
            if abs(point.x - startTouchMovePoint.x) > 20 {
                if point.x > startTouchMovePoint.x {
                    if currentRate < 2 {
                        targetRate += 0.25
                        print("加速\(targetRate)")
                    }
                }
                else {
                    if currentRate > 0.5 {
                        targetRate -= 0.25
                        print("减速\(targetRate)")
                    }
                }
            }
            player.currentPlayerControl.changeRate(targetRate) { (success) in
                if success {
                    print("当前速度\(self.player.currentPlayerControl.rate)")
                    guard let superview = self.superview else { return }
                    VDHUDLabel.show(text: "\(self.player.currentPlayerControl.rate)X", in: superview).hide(after: 2)
                }
            }
        }
        if currentGestureType == .progress {
            if !allowPanGesture { return }
            allowPanGesture = false
            progressSliderIsDragging = false
            
            let seekTime = TimeInterval(progressSlider.value)
            let percent = progressSlider.value / progressSlider.maximumValue
            
            guard let superview = self.superview else { return }
            VDHUDLabel.show(text: "\(vd_formateTime(seekTime, customFormateStr: nil))/\(vd_formateTime(player.totalTime, customFormateStr: nil))", in: superview).hide(after: 0)
            
            player.seek(to: seekTime) { (success) in
                if success {
                    self.progressSliderIsDragging = false
                }
            }
            if let didEndSlidingProgressSlider = didEndSlidingProgressSlider { didEndSlidingProgressSlider(percent) }
        }
        
        allowPanGesture = false
        allowChangeGestureType = true
        progressSliderIsDragging = false
        startTouchMovePoint = .zero
        currentGestureType = .none
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesCancelled(touches, with: event)
        allowPanGesture = false
        allowChangeGestureType = true
        progressSliderIsDragging = false
        startTouchMovePoint = .zero
        currentGestureType = .none
        
        VDHUDLabel.hide()
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
        controlPanelIsAppear = true
    }
    
    func hideControlPanel(){
        self.topView.alpha = 0
        self.bottomView.alpha = 0
        self.bottomProgressView.alpha = 1
        self.playPauseBtn.alpha = 0
        controlPanelIsAppear = false
    }
}
