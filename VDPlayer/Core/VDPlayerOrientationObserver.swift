//
//  VDPlayerOrientationObserver.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/8.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

enum VDFullScreenMode: Int {
    case automatic
    case landscape
    case portrait
}

protocol VDPlayerOrientationObserverDelegate: NSObjectProtocol {
    func orientationWillChange(observer: VDPlayerOrientationObserver, isFullScreen: Bool)
    func orientationDidChange(observer: VDPlayerOrientationObserver, isFullScreen: Bool)
}

extension VDPlayerOrientationObserverDelegate {
    func orientationWillChange(observer: VDPlayerOrientationObserver, isFullScreen: Bool) {}
    func orientationDidChange(observer: VDPlayerOrientationObserver, isFullScreen: Bool) {}
}

/// extension UIWindow CurrentViewController
extension UIWindow {
    public class func vd_currentViewController() -> UIViewController? {
        var window: UIWindow?
        if #available(iOS 13.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                if scene is UIWindowScene {
                    let windowScene: UIWindowScene = scene as! UIWindowScene
                    for windowTemp in windowScene.windows {
                        if windowTemp.isKeyWindow {
                            window = windowTemp
                            break
                        }
                    }
                    if window != nil { break }
                }
            }
        } else {
            window = UIApplication.shared.delegate?.window!
        }
        guard let w = window else { return nil }
        var topViewController = w.rootViewController
        while true {
            if let presentedViewController = topViewController?.presentedViewController {
                topViewController = presentedViewController
            } else if let navController = topViewController as? UINavigationController, let navTopViewController = navController.topViewController {
                topViewController = navTopViewController
            } else if let tabBarController = topViewController as? UITabBarController {
                topViewController = tabBarController
            } else {
                break
            }
        }
        return topViewController
    }
}

public enum VDInterfaceOrientationMask : Int {

    
    case unknown = 0

    case portrait = 1 // Device oriented vertically, home button on the bottom

    case portraitUpsideDown = 2 // Device oriented vertically, home button on the top

    case landscapeLeft = 3 // Device oriented horizontally, home button on the right

    case landscapeRight = 4 // Device oriented horizontally, home button on the left

    case faceUp = 5 // Device oriented flat, face up

    case faceDown = 6 // Device oriented flat, face down
}

@objc protocol VDPortraitOrientationDelegate: NSObjectProtocol {
    @objc optional func vd_orientationWillChange(isFullScreen: Bool)
    @objc optional func vd_orientationDidChanged(isFullScreen: Bool)
    @objc optional func vd_interationState(isDragging: Bool)
}

class VDPlayerOrientationObserver: NSObject {
    
    /// rotate duration, default is 0.30
    public var duration: TimeInterval = 0.3
    
    /// If the full screen.
    public var isFullScreen: Bool = false {
        didSet {
            window?.landscapeViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    public var fullScreenMode: VDFullScreenMode = .automatic
    
    public var portraitViewController: VDPortraitViewController?
    
    public var orientationWillChange: ((_ observer: VDPlayerOrientationObserver, _ isFullScreen: Bool) -> ())?
    
    public var orientationDidChange: ((_ observer: VDPlayerOrientationObserver, _ isFullScreen: Bool) -> ())?
    
    /// The current orientation of the player.
    /// Default is UIInterfaceOrientationPortrait.
    public private(set) var currentOrientation: UIInterfaceOrientation = .portrait
    
    public var supportInterfaceOrientation: [VDInterfaceOrientationMask] = [.portrait, .landscapeLeft, .landscapeRight]
    
    private weak var playerView: VDPlayerView? {
        willSet {
            if newValue == playerView {
                return
            }
        }
        didSet {
            if fullScreenMode == .landscape && window != nil {
                window?.landscapeViewController?.contentView = playerView
            }
            else if fullScreenMode == .portrait {
                portraitViewController?.contentView = playerView
            }
        }
    }
    private var previousKeyWindow: UIWindow?
    private var window: VDLandscapeWindow?
    var allowAutorotate: Bool = true
    weak var delegate: VDPlayerOrientationObserverDelegate?
    private var isRotating: Bool = false
    private var forceRotaion: Bool = false
    /// Container view of a full screen state player.
    var fullScreenContainerView: UIView? {
        get {
            if fullScreenMode == .landscape {
                return window?.landscapeViewController?.view
            } else if fullScreenMode == .portrait {
                return portraitViewController?.view
            }
            return nil
        }
    }
//    weak var playerView: UIView? //media
    weak var containerView: UIView? {// small size player container
        didSet {
            if fullScreenMode == .landscape && window != nil {
                window?.landscapeViewController?.containerView = containerView
            }
            else if fullScreenMode == .portrait {
                portraitViewController?.containerView = containerView
            }
        }
    }
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
    
    public func update(rotateView: VDPlayerView, containerView: UIView) {
        playerView = rotateView
        self.containerView = containerView
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
        if fullScreenMode == .portrait || !allowAutorotate {
            return
        }
        if !UIDevice.current.orientation.isValidInterfaceOrientation {
            return
        }
        let currentOrientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue) ?? .unknown

        // Determine that if the current direction is the same as the direction you want to rotate, do nothing
//        if (currentOrientation == _currentOrientation && !self.forceDeviceOrientation) return;
//        if !allowAutorotate { return }
        if currentOrientation == self.currentOrientation {
            return
        }
        self.currentOrientation = currentOrientation
        
        switch currentOrientation {
        case .portrait:
//            enterLandscapeFullScreen(orientation: .portrait, animated: true)
            rotate(to: .portrait, animated: true, completion: nil)
        case .landscapeLeft:
            rotate(to: .landscapeLeft, animated: true, completion: nil)
        case .landscapeRight:
            rotate(to: .landscapeRight, animated: true, completion: nil)
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
            UIView.animate(withDuration: duration, animations: {
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
            UIView.animate(withDuration: duration, animations: {
                playerView.transform = self.getTransformRotationAngle(orientation)
                UIView.animate(withDuration: self.duration, animations: {
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
    
    func enterPortraitMode(fullScreen: Bool, animated: Bool, completion:((_ completion: Bool)->())? = nil) {
////        if fullScreen {
////
////        }
////        else {
////
////        }
////        isFullScreen = fullScreen
////        delegate?.orientationWillChange(observer: self, isFullScreen: isFullScreen)
////        if animate {
////            UIView.animate(withDuration: animateDuration, animations: {
////                self.interfaceOrientation(orientation: .portrait)
////            }) { (complate) in
////                self.delegate?.orientationDidChange(observer: self, isFullScreen: self.isFullScreen)
////            }
////        }
////        else {
////            UIView.performWithoutAnimation {
////                self.interfaceOrientation(orientation: .portrait)
////            }
////            delegate?.orientationDidChange(observer: self, isFullScreen: isFullScreen)
////        }
////        //        UIApplication.shared.statusBarOrientation = .portrait
//////        UIApplication.shared.setStatusBarOrientation(.portrait, animated: animate)
//        var superview: UIView? = nil
//        guard let playerView = playerView else { return }
//        if fullScreen {
//            superview = fullScreenContainerView
//            playerView.frame = playerView.convert(playerView.frame, to: superview)
//            superview?.addSubview(playerView)
//            isFullScreen = true
//        } else {
////            if roateType == ZFRotateTypeCell {
////                superview = cell.viewWithTag(playerViewTag)
////            } else {
//                superview = containerView
////            }
//            isFullScreen = false
//        }
//        delegate?.orientationWillChange(observer: self, isFullScreen: isFullScreen)
//        let frame = superview?.convert(superview?.bounds ?? CGRect.zero, to: fullScreenContainerView)
//        if animated {
//            UIView.animate(withDuration: duration, animations: {
//                playerView.frame = frame ?? .zero
//                playerView.layoutIfNeeded()
//            }) { finished in
//                superview?.addSubview(playerView)
//                playerView.frame = superview?.bounds ?? .zero
//                self.delegate?.orientationDidChange(observer: self, isFullScreen: self.isFullScreen)
//            }
//        } else {
//            superview?.addSubview(playerView)
//            playerView.frame = superview?.bounds ?? .zero
//            playerView.layoutIfNeeded()
//            delegate?.orientationDidChange(observer: self, isFullScreen: isFullScreen)
//        }
        isFullScreen = fullScreen
        if isFullScreen {
            
        }
        else {
            portraitViewController?.fullScreenAnimation = animated
            portraitViewController?.dismiss(animated: animated, completion: {
                completion?(true)
            })
        }
    }
        
    func enterLandscapeFullScreen(orientation: UIInterfaceOrientation, animated: Bool, completion:((_ completion: Bool)->())? = nil) {
        normalOrientation(orientation: orientation, animate: animated)
//        enterPortraitMode(fullScreen: true, animate: animate)
    }
    
    func exitFullScreen(animate: Bool) {
        normalOrientation(orientation: .portrait, animate: animate)
//        enterPortraitMode(fullScreen: false, animate: true)
    }
    
    func rotate(to orientation: UIInterfaceOrientation, animated: Bool, completion: ((_ completion: Bool)->())? = nil) {
        if fullScreenMode == .portrait {
            return
        }
        guard let playerView = playerView else {
            return
        }
        currentOrientation = orientation
        forceRotaion = true
        if orientation.isLandscape {
            if !isFullScreen {
                var containerView: UIView?
//                if rotateType == ZFRotateTypeCell {
//                    containerView = cell.viewWithTag(playerViewTag)
//                } else {
                    containerView = self.containerView
//                }
                let targetRect = playerView.convert(playerView.frame, to: containerView?.window)

                if (window == nil) {
                    window = VDLandscapeWindow(frame: UIScreen.main.bounds)
                    if let window = window {
                        window.landscapeViewController?.delegate = self
                        if #available(iOS 9.0, *) {
                            window.rootViewController?.loadViewIfNeeded()
                        } else {
                            let _ = window.rootViewController?.view
                        }
                    }
                }

                guard let window = window else { return }
                window.landscapeViewController?.targetRect = targetRect
                window.landscapeViewController?.contentView = playerView
                window.landscapeViewController?.containerView = containerView
                isFullScreen = true
            }
//            orientationWillChange?(self, isFullScreen)
            delegate?.orientationWillChange(observer: self, isFullScreen: isFullScreen)
            
        } else {
            isFullScreen = false
        }
        guard let window = window else { return }
        window.landscapeViewController?.disableAnimations = !animated
        window.landscapeViewController?.rotatingCompleted = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.forceRotaion = false
            completion?(true)
        }

        interfaceOrientation(orientation: .unknown)
        interfaceOrientation(orientation: orientation)
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

extension VDPlayerOrientationObserver: VDLandscapeViewControllerDelegate {
    func vd_shouldAutorotate() -> Bool {
        if fullScreenMode == .portrait {
            return false
        }
        
        let currentOrientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue) ?? .unknown
        if !_isSupported(orientation: currentOrientation) {
            return false
        }
        
        if forceRotaion {
            _rotation(toLandscapeOrientation: currentOrientation)
            return true
        }
        
        _rotation(toLandscapeOrientation: currentOrientation)
        return true
    }
    
    func vd_willRotateToOrientation(orientation: UIInterfaceOrientation) {
        isFullScreen = orientation.isLandscape
        orientationWillChange?(self, isFullScreen)
    }
    
    func vd_didRotateFromOrientation(orientation: UIInterfaceOrientation) {
        orientationDidChange?(self, isFullScreen)
        if !isFullScreen {
            _rotation(toLandscapeOrientation: .portrait)
        }
    }
    
    func vd_targetRect() -> CGRect {
        var containerView: UIView?
        containerView = self.containerView
        if containerView != nil {
            let targetRect = containerView?.convert(containerView!.bounds, to: containerView!.window)
            return targetRect ?? .zero
        }
        else {
            return .zero
        }
    }
}

// MARK: - Private
extension VDPlayerOrientationObserver {
    private func interfaceOrientation(orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
    
    private func _isSupportedPortrait() -> Bool {
        return supportInterfaceOrientation.contains(.portrait)
    }
    
    private func _isSupportedLandscapeLeft() -> Bool {
        return supportInterfaceOrientation.contains(.landscapeLeft)
    }
    
    private func _isSupportedLandscapeRight() -> Bool {
        return supportInterfaceOrientation.contains(.landscapeRight)
    }
    
    private func _isSupported(orientation: UIInterfaceOrientation) -> Bool {
        switch orientation {
        case .portrait:
            return supportInterfaceOrientation.contains(.portrait)
        case .landscapeLeft:
            return supportInterfaceOrientation.contains(.landscapeLeft)
        case .landscapeRight:
            return supportInterfaceOrientation.contains(.landscapeRight)
        default:
            return false
        }
    }
    
    private func _rotation(toLandscapeOrientation orientation: UIInterfaceOrientation) {
        if orientation.isLandscape {
            let keyWindow = UIApplication.shared.keyWindow
            if keyWindow != window && previousKeyWindow != keyWindow {
                previousKeyWindow = UIApplication.shared.keyWindow
            }
            if !(window?.isKeyWindow ?? false) {
                window?.isHidden = false
                window?.makeKeyAndVisible()
            }
        }
    }
    
//    - (void)_rotationToPortraitOrientation:(UIInterfaceOrientation)orientation {
//        if (orientation == UIInterfaceOrientationPortrait && !self.window.hidden) {
//            UIView *containerView = nil;
//            if (self.rotateType == ZFRotateTypeCell) {
//                containerView = [self.cell viewWithTag:self.playerViewTag];
//            } else {
//                containerView = self.containerView;
//            }
//            UIView *snapshot = [self.view snapshotViewAfterScreenUpdates:NO];
//            snapshot.frame = containerView.bounds;
//            [containerView addSubview:snapshot];
//            [self performSelector:@selector(_contentViewAdd:) onThread:NSThread.mainThread withObject:containerView waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
//            [self performSelector:@selector(_makeKeyAndVisible:) onThread:NSThread.mainThread withObject:snapshot waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
//        }
//    }
    private func _rotation(toPortraitOrientation orientation: UIInterfaceOrientation) {
        if orientation.isPortrait && !(window?.isHidden ?? true) {
            var containerView: UIView?
            containerView = self.containerView
            if let snapshot = playerView?.snapshotView(afterScreenUpdates: false) {
                snapshot.frame = containerView?.bounds ?? .zero
                containerView?.addSubview(snapshot)
            }
            perform(#selector(_contentViewAdd(containerView:)))
            perform(#selector(_makeKeyAndVisible(snapshot:)))
        }
    }
    
    @objc private func _contentViewAdd(containerView: UIView) {
        guard let playerView = playerView else { return }
        containerView.addSubview(playerView)
        playerView.frame = containerView.bounds
        playerView.layoutIfNeeded()
    }
    
    @objc private func _makeKeyAndVisible(snapshot: UIView) {
        snapshot.removeFromSuperview()
        let previousKeyWindow = (self.previousKeyWindow != nil) ? self.previousKeyWindow : UIApplication.shared.windows.first
        previousKeyWindow?.makeKeyAndVisible()
        self.previousKeyWindow = nil
        window?.isHidden = true
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
