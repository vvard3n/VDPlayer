//
//  VDLandscapeViewController.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2020/11/30.
//  Copyright © 2020 vvard3n. All rights reserved.
//

import UIKit

@objc public protocol VDLandscapeViewControllerDelegate: NSObjectProtocol {
    @objc optional func vd_shouldAutorotate() -> Bool
    @objc optional func vd_willRotateToOrientation(orientation: UIInterfaceOrientation)
    @objc optional func vd_didRotateFromOrientation(orientation: UIInterfaceOrientation)
    @objc optional func vd_targetRect() -> CGRect
}

class VDLandscapeViewController: UIViewController {
    
    private var currentOrientation: UIInterfaceOrientation = .portrait
    public weak var contentView: UIView?
    public weak var containerView: UIView?
    public var targetRect: CGRect = .zero
    public weak var delegate: VDLandscapeViewControllerDelegate?
    public var isFullscreen: Bool { return currentOrientation.isLandscape }
    public var isRotating: Bool = false {
        didSet {
            if oldValue != isRotating {
                rotatingCompleted?()
            }
        }
    }
    public var disableAnimations: Bool = false
    public var statusBarHidden: Bool = false
    /// default is  UIStatusBarStyleLightContent.
    public var statusBarStyle: UIStatusBarStyle = .lightContent
    /// defalut is UIStatusBarAnimationSlide.
    public var statusBarAnimation: UIStatusBarAnimation = .slide
    public var rotatingCompleted: (()->())?
    
//    public init() {
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        isRotating = true
        super.viewWillTransition(to: size, with: coordinator)
        if !UIDevice.current.orientation.isValidInterfaceOrientation {
            return
        }
        guard let contentView = contentView else { return }
        guard let containerView = containerView else { return }
        let newOrientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue) ?? .unknown
        let oldOrientation = currentOrientation
        if newOrientation.isLandscape {
            if contentView.superview != view {
                view.addSubview(contentView)
            }
        }

        if oldOrientation == .portrait {
            contentView.frame = delegate?.vd_targetRect?() ?? .zero
            contentView.layoutIfNeeded()
        }
        currentOrientation = newOrientation

        delegate?.vd_willRotateToOrientation?(orientation: currentOrientation)
        let isFullscreen = size.width > size.height
        CATransaction.begin()
        CATransaction.setDisableActions(disableAnimations)
        coordinator.animate { (context) in
            if isFullscreen {
                contentView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            }
            else {
                contentView.frame = self.delegate?.vd_targetRect?() ?? .zero
            }
            contentView.layoutIfNeeded()
        } completion: { (context) in
            CATransaction.commit()
            self.delegate?.vd_didRotateFromOrientation?(orientation: self.currentOrientation)
            if !isFullscreen {
                contentView.frame = containerView.bounds
                contentView.layoutIfNeeded()
            }
            self.disableAnimations = false
            self.isRotating = false
        }

    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return delegate?.vd_shouldAutorotate?() ?? false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let currentOrientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue) ?? .unknown
        if currentOrientation.isLandscape {
            return .landscape
        }
        return .all
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        let currentOrientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue) ?? .unknown
        return currentOrientation.isLandscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarAnimation
    }
    
}
