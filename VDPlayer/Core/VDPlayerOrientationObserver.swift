//
//  VDPlayerOrientationObserver.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/8.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

protocol VDPlayerOrientationObserverDelegate: NSObjectProtocol {
    func orientationWillChange(observer: VDPlayerOrientationObserver, isFullScreen: Bool)
    func orientationDidChange(observer: VDPlayerOrientationObserver, isFullScreen: Bool)
}

extension VDPlayerOrientationObserverDelegate {
    func orientationWillChange(observer: VDPlayerOrientationObserver, isFullScreen: Bool) {}
    func orientationDidChange(observer: VDPlayerOrientationObserver, isFullScreen: Bool) {}
}

class VDPlayerOrientationObserver: NSObject {
    
    weak var delegate: VDPlayerOrientationObserverDelegate?
    var isFullScreen: Bool = false
    var animateDuration: TimeInterval = 0.3
    var fullScreenContainerView: UIView? {
        get {
            return UIApplication.shared.keyWindow
        }
    }
    private weak var view: UIView?
    weak var containerView: UIView?
    
    func addDeviceOrientationObserver() {
        if UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func removeDeviceOrientationObserver() {
        if UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}

// MARK: - Handel
extension VDPlayerOrientationObserver {
    @objc private func deviceOrientationDidChange(_ notification: Notification) {
        
    }
}

extension VDPlayerOrientationObserver {
    func enterLandscapeFullScreen(orientation: UIInterfaceOrientation, animate: Bool) {
//        isFullScreen = true
//        delegate?.orientationWillChange(observer: self, isFullScreen: isFullScreen)
//        UIViewController.attemptRotationToDeviceOrientation()
//        if animate {
//            UIView.animate(withDuration: animateDuration, animations: {
//                self.interfaceOrientation(orientation: orientation)
//            }) { (complate) in
//                self.delegate?.orientationDidChange(observer: self, isFullScreen: self.isFullScreen)
//            }
//        }
//        else {
//            UIView.performWithoutAnimation {
//                self.interfaceOrientation(orientation: orientation)
//            }
//            delegate?.orientationDidChange(observer: self, isFullScreen: isFullScreen)
//        }
//        //        UIApplication.shared.statusBarOrientation = orientation
////        UIApplication.shared.setStatusBarOrientation(orientation, animated: animate)
        
        var superview: UIView? = nil
        guard let view = view else { return }
        if isFullScreen {
            superview = fullScreenContainerView
            view.frame = view.convert(view.frame, to: superview)
            superview?.addSubview(view)
            isFullScreen = true
        } else {
//            if roateType == ZFRotateTypeCell {
//                superview = cell.viewWithTag(playerViewTag)
//            } else {
                superview = containerView
//            }
            isFullScreen = false
        }
        delegate?.orientationWillChange(observer: self, isFullScreen: isFullScreen)
        UIViewController.attemptRotationToDeviceOrientation()
        
        guard let frame = superview?.convert(superview?.bounds ?? CGRect.zero, to: fullScreenContainerView) else { return }
        if animate {
            UIView.animate(withDuration: animateDuration, animations: {
                view.frame = frame
                view.layoutIfNeeded()
            }) { finished in
                superview?.addSubview(view)
                view.frame = superview?.bounds ?? .zero
                self.delegate?.orientationDidChange(observer: self, isFullScreen: self.isFullScreen)
            }
        } else {
            superview?.addSubview(view)
            view.frame = superview?.bounds ?? .zero
            view.layoutIfNeeded()
            delegate?.orientationDidChange(observer: self, isFullScreen: isFullScreen)
        }
    }
    
    func enterPortraitMode(fullScreen: Bool, animate: Bool) {
        if fullScreen {
            
        }
        else {
            
        }
        isFullScreen = fullScreen
        delegate?.orientationWillChange(observer: self, isFullScreen: isFullScreen)
        if animate {
            UIView.animate(withDuration: animateDuration, animations: {
                self.interfaceOrientation(orientation: .portrait)
            }) { (complate) in
                self.delegate?.orientationDidChange(observer: self, isFullScreen: self.isFullScreen)
            }
        }
        else {
            UIView.performWithoutAnimation {
                self.interfaceOrientation(orientation: .portrait)
            }
            delegate?.orientationDidChange(observer: self, isFullScreen: isFullScreen)
        }
        //        UIApplication.shared.statusBarOrientation = .portrait
//        UIApplication.shared.setStatusBarOrientation(.portrait, animated: animate)
    }
    
    func exitFullScreen(animate: Bool) {
        enterPortraitMode(fullScreen: false, animate: true)
    }
}

// MARK: - Private
extension VDPlayerOrientationObserver {
    private func interfaceOrientation(orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
}
