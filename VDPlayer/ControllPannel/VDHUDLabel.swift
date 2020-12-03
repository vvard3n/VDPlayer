//
//  VDHUDLabel.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/5/14.
//  Copyright © 2019 vvard3n. All rights reserved.
//

import UIKit

class VDHUDLabel: UILabel {

    var textInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    var animateTime: TimeInterval = 0.3
    var autoHidden: Bool = false
    var autoHiddenTime: TimeInterval = 2
    var autoHiddenAnimate: Bool = false
    private var autoHiddenWorkItem: DispatchWorkItem?
    
    var isAppeard: Bool = false
    
    static let shard: VDHUDLabel = {
        let hudLabel = VDHUDLabel()
        hudLabel.font = .systemFont(ofSize: 12)
        hudLabel.textColor = .white
        hudLabel.textAlignment = .center
        hudLabel.backgroundColor = UIColor(white: 0, alpha: 0.5)
        hudLabel.layer.cornerRadius = 2
        hudLabel.layer.masksToBounds = true
        hudLabel.translatesAutoresizingMaskIntoConstraints = false
        hudLabel.alpha = 0
        return hudLabel
    }()
    
    private init() {
        super.init(frame: .zero)
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult class func show(text: String, in view: UIView) -> VDHUDLabel {
        let hud = VDHUDLabel.shard
        hud.text = text
        hud.showInView(view, animated: true)
        
//        func hidden(after: TimeInterval) {
//            if hud.isAppeard {
//                hud.cancelAutoHiddenHUD()
//            }
//            hud.startAutoHiddenHUD(after: after)
//        }
        return hud
    }
    
    class func hide(after: TimeInterval = 0) {
        VDHUDLabel.shard.hide(after: after)
    }
    
    func hide(after: TimeInterval) {
        startAutoHiddenHUD(after: after)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += textInsets.left + textInsets.right
        size.height += textInsets.top + textInsets.bottom
        return size
    }
    
    func startAutoHiddenHUD(after: TimeInterval = 2) {
        cancelAutoHiddenHUD()
        
        autoHiddenWorkItem = DispatchWorkItem { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.hideHUD(animated: true)
        }
        guard let autoHiddenWorkItem = autoHiddenWorkItem else { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + after, execute: autoHiddenWorkItem)
    }
    
    func cancelAutoHiddenHUD() {
        if let autoHiddenWorkItem = autoHiddenWorkItem {
            autoHiddenWorkItem.cancel()
            self.autoHiddenWorkItem = nil
        }
    }
    
    func showInView(_ view: UIView, animated: Bool) {
        isAppeard = true
        view.addSubview(self)
        view.addConstraints([NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)])
        if animated {
            UIView.animate(withDuration: animateTime, animations: {
                self.alpha = 1
            }) { (success) in
                if self.autoHidden {
                    self.hideHUD(animated: self.autoHiddenAnimate)
                    self.startAutoHiddenHUD()
                }
            }
        }
        else {
            self.alpha = 1
            if self.autoHidden {
                self.hideHUD(animated: self.autoHiddenAnimate)
                self.startAutoHiddenHUD()
            }
        }
        
    }
    
    func hideHUD(animated: Bool/*, after: TimeInterval = 0*/) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
        isAppeard = false
            if animated {
                UIView.animate(withDuration: self.animateTime, animations: {
                    self.alpha = 0
                }) { (success) in
                    self.removeFromSuperview()
                }
            }
            else {
                self.removeFromSuperview()
            }
//        }
    }
}
