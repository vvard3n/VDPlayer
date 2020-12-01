//
//  VDPresentTransition.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2020/11/30.
//  Copyright © 2020 vvard3n. All rights reserved.
//

import UIKit

enum VDPresentTransitionType: Int {
    case present
    case dismiss
}

class VDPresentTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    public weak var delegate: VDPortraitOrientationDelegate?
    public var duration: TimeInterval = 0
    public var contentFullScreenRect: CGRect = .zero {
        didSet {
            if !isTransiting && isFullScreen && !isInteration {
                contentView?.frame = contentFullScreenRect
            }
        }
    }
    public var isFullScreen: Bool = false
    public var isInteration: Bool = false
    private var contentView: UIView?
    private var containerView: UIView?
    private var type: VDPresentTransitionType = .present
    private var isTransiting: Bool = false
    
    public func transition(type: VDPresentTransitionType, contentView: UIView?, containerView: UIView?) {
        self.type = type
        self.contentView = contentView
        self.containerView = containerView
    }
    
    func presentAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let contentView = contentView else {
            return
        }
        let toVC = transitionContext.viewController(forKey: .to)
        var fromVC = transitionContext.viewController(forKey: .from)
        if fromVC is UINavigationController {
            let nav = fromVC as? UINavigationController
            fromVC = nav?.viewControllers.last
        } else if fromVC is UITabBarController {
            let tabBar = fromVC as? UITabBarController
            if tabBar?.selectedViewController is UINavigationController {
                let nav = tabBar?.selectedViewController as? UINavigationController
                fromVC = nav?.viewControllers.last
            } else {
                fromVC = tabBar?.selectedViewController
            }
        }
        let containerView = transitionContext.containerView
        if let view = toVC?.view {
            containerView.addSubview(view)
        }
        containerView.addSubview(contentView)
        let originRect = self.containerView?.convert(contentView.frame, to: toVC?.view)
        contentView.frame = originRect ?? CGRect.zero

        let tempColor = toVC?.view.backgroundColor
        toVC?.view.backgroundColor = tempColor?.withAlphaComponent(0)
        toVC?.view.alpha = 1
        delegate?.vd_orientationWillChange?(isFullScreen: true)

        let toRect = contentFullScreenRect
        isTransiting = true
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            contentView.frame = toRect
            contentView.layoutIfNeeded()
            toVC?.view.backgroundColor = tempColor?.withAlphaComponent(1.0)
        }) { [weak self] finished in
            guard let weakSelf = self else { return }
            weakSelf.isTransiting = false
            toVC?.view.addSubview(contentView)
            transitionContext.completeTransition(true)
            weakSelf.delegate?.vd_orientationDidChanged?(isFullScreen: true)
            if !toRect.equalTo(weakSelf.contentFullScreenRect) {
                contentView.frame = weakSelf.contentFullScreenRect
                contentView.layoutIfNeeded()
            }
        }
    }
    
    func dismissAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let contentView = contentView else {
            return
        }
        let containerView = transitionContext.containerView
        var toVC = transitionContext.viewController(forKey: .to)
        if toVC is UINavigationController {
            let nav = toVC as? UINavigationController
            toVC = nav?.viewControllers.last
        } else if toVC is UITabBarController {
            let tabBar = toVC as? UITabBarController
            if tabBar?.selectedViewController is UINavigationController {
                let nav = tabBar?.selectedViewController as? UINavigationController
                toVC = nav?.viewControllers.last
            } else {
                toVC = tabBar?.selectedViewController
            }
        }
        
        let fromVC = transitionContext.viewController(forKey: .from)
        fromVC?.view.frame = containerView.bounds
        if let view = fromVC?.view {
            containerView.addSubview(view)
        }
        containerView.addSubview(contentView)
        
        let originRect = fromVC?.view.convert(contentView.frame, to: toVC?.view)
        contentView.frame = originRect ?? CGRect.zero
        let toRect = self.containerView?.convert(self.containerView?.bounds ?? CGRect.zero, to: toVC?.view)
        fromVC?.view.convert(contentView.bounds, to: self.containerView?.window)
        delegate?.vd_orientationWillChange?(isFullScreen: false)
        isTransiting = true
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC?.view.alpha = 0
            contentView.frame = toRect ?? CGRect.zero
            contentView.layoutIfNeeded()
        }) { [weak self] finished in
            guard let weakSelf = self else { return }
            weakSelf.containerView?.addSubview(contentView)
            contentView.frame = weakSelf.containerView?.bounds ?? CGRect.zero
            transitionContext.completeTransition(true)
            weakSelf.delegate?.vd_orientationDidChanged?(isFullScreen: false)
            weakSelf.isTransiting = false
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration == 0 ? 0.25 : duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch type {
        case .present:
            presentAnimation(transitionContext: transitionContext)
        case .dismiss:
            dismissAnimation(transitionContext: transitionContext)
        }
    }
    
}
