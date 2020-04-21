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
    weak var playerView: UIView? //media
    weak var containerView: UIView? // small size player container
    private lazy var fullScreenWindow: UIWindow = { // fullscreen window
        if #available(iOS 13.0, *) {
            var windowScene: UIWindowScene? = nil
            for scene in UIApplication.shared.connectedScenes {
                if scene.activationState == .foregroundActive {
                    windowScene = scene as? UIWindowScene
                }
                if windowScene == nil && UIApplication.shared.connectedScenes.count == 1 {
                    windowScene = scene as? UIWindowScene
                }
            }
            if let windowScene = windowScene {
                return UIWindow(windowScene: windowScene)
            } else {
                return UIWindow(frame: CGRect.zero)
            }
        }
        return UIWindow(frame: CGRect.zero)
    }()
    
    deinit {
        removeDeviceOrientationObserver()
    }
    
    override init() {
        super.init()
        addDeviceOrientationObserver()
    }
    
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
        var currentOrientation = UIInterfaceOrientation.unknown
        if UIDevice.current.orientation.isValidInterfaceOrientation {
            currentOrientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue) ?? .unknown
        }
        else {
            return
        }

        // Determine that if the current direction is the same as the direction you want to rotate, do nothing
//        if (currentOrientation == _currentOrientation && !self.forceDeviceOrientation) return;
        
        switch currentOrientation {
        case .portrait:
            enterLandscapeFullScreen(orientation: .portrait, animate: true)
        case .landscapeLeft:
            enterLandscapeFullScreen(orientation: .landscapeLeft, animate: true)
        case .landscapeRight:
            enterLandscapeFullScreen(orientation: .landscapeRight, animate: true)
        default:
            break
        }
    }
}

extension VDPlayerOrientationObserver {
    func forceDeviceOrientation(orientation: UIInterfaceOrientation, animate: Bool) {
        
        var superview: UIView? = nil
        guard let playerView = playerView else { return }
        if !isFullScreen {
            superview = fullScreenContainerView
            playerView.frame = playerView.convert(playerView.frame, to: superview)
            superview?.addSubview(playerView)
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
                playerView.frame = frame
                playerView.layoutIfNeeded()
                self.interfaceOrientation(orientation: orientation)
            }) { finished in
                superview?.addSubview(playerView)
                playerView.frame = superview?.bounds ?? .zero
                self.delegate?.orientationDidChange(observer: self, isFullScreen: self.isFullScreen)
            }
        } else {
            superview?.addSubview(playerView)
            playerView.frame = superview?.bounds ?? .zero
            playerView.layoutIfNeeded()
            UIView.performWithoutAnimation {
                self.interfaceOrientation(orientation: orientation)
            }
            delegate?.orientationDidChange(observer: self, isFullScreen: isFullScreen)
        }
    }
    
    func normalOrientation(orientation: UIInterfaceOrientation, animate: Bool) {
        var superview: UIView? = nil
        var frame: CGRect
        guard let playerView = playerView else { return }
        if orientation.isLandscape {
            superview = fullScreenContainerView
            /// It's not set from the other side of the screen to this side
            if !isFullScreen {
                playerView.frame = playerView.convert(playerView.frame, to: superview)
            }
            superview?.addSubview(playerView)
            isFullScreen = true
            delegate?.orientationWillChange(observer: self, isFullScreen: isFullScreen)

            let fullVC = VDPlayerFullScreenVC()
            if orientation == .landscapeLeft {
                fullVC.interfaceOrientationMask = UIInterfaceOrientationMask.landscapeLeft
            } else {
                fullVC.interfaceOrientationMask = UIInterfaceOrientationMask.landscapeRight
            }
            fullScreenWindow.rootViewController = fullVC
        } else {
            isFullScreen = false
            delegate?.orientationWillChange(observer: self, isFullScreen: isFullScreen)
            let fullVC = VDPlayerFullScreenVC()
            fullVC.interfaceOrientationMask = UIInterfaceOrientationMask.portrait
            fullScreenWindow.rootViewController = fullVC

//            if roateType == ZFRotateTypeCell {
//                superview = cell.viewWithTag(playerViewTag)
//            } else {
                superview = containerView
//            }
//            if blackView.superview != nil {
//                blackView.removeFromSuperview()
            //            }
        }
        frame = superview?.convert(superview?.bounds ?? CGRect.zero, to: fullScreenContainerView) ?? CGRect.zero
        
        if animate {
            UIView.animate(withDuration: animateDuration, animations: {
                playerView.transform = self.getTransformRotationAngle(orientation)
                UIView.animate(withDuration: self.animateDuration, animations: {
                    playerView.frame = frame
                    playerView.layoutIfNeeded()
                })
            }) { finished in
                superview?.addSubview(playerView)
                playerView.frame = superview?.bounds ?? .zero
                if self.isFullScreen {
                    //                    superview?.insertSubview(self.blackView, belowSubview: self.view)
                    //                    self.blackView.frame = superview?.bounds
                }
            }
            delegate?.orientationDidChange(observer: self, isFullScreen: isFullScreen)
        } else {
            playerView.transform = self.getTransformRotationAngle(orientation)
            superview?.addSubview(playerView)
            playerView.frame = superview?.bounds ?? .zero
            playerView.layoutIfNeeded()
            if self.isFullScreen {
                //                    superview?.insertSubview(self.blackView, belowSubview: self.view)
                //                    self.blackView.frame = superview?.bounds
            }
            delegate?.orientationDidChange(observer: self, isFullScreen: isFullScreen)
        }
    }
    
    func enterPortraitMode(fullScreen: Bool, animate: Bool) {
//        if fullScreen {
//
//        }
//        else {
//
//        }
//        isFullScreen = fullScreen
//        delegate?.orientationWillChange(observer: self, isFullScreen: isFullScreen)
//        if animate {
//            UIView.animate(withDuration: animateDuration, animations: {
//                self.interfaceOrientation(orientation: .portrait)
//            }) { (complate) in
//                self.delegate?.orientationDidChange(observer: self, isFullScreen: self.isFullScreen)
//            }
//        }
//        else {
//            UIView.performWithoutAnimation {
//                self.interfaceOrientation(orientation: .portrait)
//            }
//            delegate?.orientationDidChange(observer: self, isFullScreen: isFullScreen)
//        }
//        //        UIApplication.shared.statusBarOrientation = .portrait
////        UIApplication.shared.setStatusBarOrientation(.portrait, animated: animate)
        var superview: UIView? = nil
        guard let playerView = playerView else { return }
        if fullScreen {
            superview = fullScreenContainerView
            playerView.frame = playerView.convert(playerView.frame, to: superview)
            superview?.addSubview(playerView)
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
        let frame = superview?.convert(superview?.bounds ?? CGRect.zero, to: fullScreenContainerView)
        if animate {
            UIView.animate(withDuration: animateDuration, animations: {
                playerView.frame = frame ?? .zero
                playerView.layoutIfNeeded()
            }) { finished in
                superview?.addSubview(playerView)
                playerView.frame = superview?.bounds ?? .zero
                self.delegate?.orientationDidChange(observer: self, isFullScreen: self.isFullScreen)
            }
        } else {
            superview?.addSubview(playerView)
            playerView.frame = superview?.bounds ?? .zero
            playerView.layoutIfNeeded()
            delegate?.orientationDidChange(observer: self, isFullScreen: isFullScreen)
        }
    }
        
    func enterLandscapeFullScreen(orientation: UIInterfaceOrientation, animate: Bool) {
        normalOrientation(orientation: orientation, animate: animate)
//        enterPortraitMode(fullScreen: true, animate: animate)
    }
    
    func exitFullScreen(animate: Bool) {
        normalOrientation(orientation: .portrait, animate: animate)
//        enterPortraitMode(fullScreen: false, animate: true)
    }
    
    func getTransformRotationAngle(_ orientation: UIInterfaceOrientation) -> CGAffineTransform {
        if orientation == .portrait {
            return .identity
        } else if orientation == .landscapeLeft {
            return CGAffineTransform(rotationAngle: CGFloat(-(Double.pi / 2)))
        } else if orientation == .landscapeRight {
            return CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        }
        return .identity
    }
}

// MARK: - Private
extension VDPlayerOrientationObserver {
    private func interfaceOrientation(orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
}

class VDPlayerFullScreenVC: UIViewController {
    
    var interfaceOrientationMask: UIInterfaceOrientationMask = .allButUpsideDown
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return interfaceOrientationMask
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
