//
//  VDLandscapeWindow.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2020/11/30.
//  Copyright © 2020 vvard3n. All rights reserved.
//

import UIKit

class VDLandscapeWindow: UIWindow {
    var landscapeViewController: VDLandscapeViewController?
    
    override var backgroundColor: UIColor? {
        set { }
        get { return super.backgroundColor }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        windowLevel = .normal
        landscapeViewController = VDLandscapeViewController()
        rootViewController = landscapeViewController
        if #available(iOS 13.0, *) {
            if windowScene == nil {
                windowScene = UIApplication.shared.keyWindow?.windowScene
            }
        }
        isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var bounds: CGRect = .zero
        if !bounds.equalTo(self.bounds) {
            var superview: UIView? = self
            if #available(iOS 13.0, *) {
                superview = self.subviews.first
            }
            guard let sv = superview else { return }
            UIView.performWithoutAnimation {
                for view in sv.subviews {
                    if view != rootViewController?.view && view.isMember(of: UIView.self) {
                        view.backgroundColor = .clear
                        for subview in view.subviews {
                            subview.backgroundColor = .clear
                        }
                    }
                }
            }
        }
        bounds = self.bounds
        rootViewController?.view.frame = bounds
    }
}
