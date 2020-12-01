//
//  VDPortraitViewController.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2020/11/30.
//  Copyright © 2020 vvard3n. All rights reserved.
//

import UIKit

class VDPortraitViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    /// The block invoked When player will rotate.
//    @property (nonatomic, copy, nullable) void(^orientationWillChange)(BOOL isFullScreen);
    public var orientationWillChange: ((_ isFullScreen: Bool)->())?

    /// The block invoked when player rotated.
    public var orientationDidChanged: ((_ isFullScreen: Bool)->())?
    
    public var contentView: UIView?
    
    public var containerView: UIView?
    
    public var isStatusBarHidden: Bool = false

    /// default is  UIStatusBarStyleLightContent.
    public var statusBarStyle: UIStatusBarStyle = .lightContent
    /// defalut is UIStatusBarAnimationSlide.
    public var statusBarAnimation: UIStatusBarAnimation = .slide
    

    /// default is VDDisablePortraitGestureTypesNone.
//    @property (nonatomic, assign) ZFDisablePortraitGestureTypes disablePortraitGestureTypes;
    public var presentationSize: CGSize = .zero
    
    public var fullScreenAnimation: Bool = false {
        didSet {
            
        }
    }
    
    public var duration: TimeInterval = 0.3 {
        didSet {
            transition.duration = duration
        }
    }
    
    private var isFullScreen: Bool = false {
        didSet {
            transition.isFullScreen = isFullScreen
        }
    }
    
    private lazy var transition: VDPresentTransition = {
        let transition = VDPresentTransition()
        transition.contentFullScreenRect = contentFullScreenRect()
        transition.delegate = self
        return transition
    }()
    
//    private lazy var interactiveTransition: VDPersentInteractiveTransition

    init() {
        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = self
        modalPresentationStyle = .overFullScreen
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transition(type: .present, contentView: contentView, containerView: containerView)
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transition(type: .dismiss, contentView: contentView, containerView: containerView)
        return transition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarAnimation
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func contentFullScreenRect() -> CGRect {
        var videoWidth = presentationSize.width
        var videoHeight = presentationSize.height
        if videoHeight == 0 {
            return CGRect.zero
        }
        var fullScreenScaleSize = CGSize.zero
        let screenScale = CGFloat(SCREEN_WIDTH / SCREEN_HEIGHT)
        let videoScale = videoWidth / videoHeight
        if screenScale > videoScale {
            let height = CGFloat(SCREEN_HEIGHT)
            let width = height * videoScale
            fullScreenScaleSize = CGSize(width: width, height: height)
        } else {
            let width = CGFloat(SCREEN_WIDTH)
            let height = width / videoScale
            fullScreenScaleSize = CGSize(width: width, height: height)
        }

        videoWidth = fullScreenScaleSize.width
        videoHeight = fullScreenScaleSize.height
        let rect = CGRect(x: (CGFloat(SCREEN_WIDTH) - videoWidth) / 2.0, y: (CGFloat(SCREEN_HEIGHT) - videoHeight) / 2.0, width: videoWidth, height: videoHeight)
        return rect
    }
}

extension VDPortraitViewController: VDPortraitOrientationDelegate {
    func vd_interationState(isDragging: Bool) {
        transition.isInteration = isDragging
    }
    
    func vd_orientationWillChange(isFullScreen: Bool) {
        orientationWillChange?(isFullScreen)
    }
    
    func vd_orientationDidChanged(isFullScreen: Bool) {
        orientationDidChanged?(isFullScreen)
    }
}
