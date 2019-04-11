//
//  VDPlayerGestureControl.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

protocol VDPlayerGestureControlDelegate: NSObjectProtocol {
    func vd_playerGestureControlSingleTaped()
    func vd_playerGestureControlDoubleTaped()
    func vd_playerGestureControlPan(_ pan: UIPanGestureRecognizer)
}

extension VDPlayerGestureControlDelegate {
    func vd_playerGestureControlSingleTaped() {}
    func vd_playerGestureControlDoubleTaped() {}
    func vd_playerGestureControlPan(_ pan: UIPanGestureRecognizer) {}
}

class VDPlayerGestureControl: NSObject {
    weak var delegate: VDPlayerGestureControlDelegate?
    
    weak var target: UIView?
    
    lazy var singleTap: UITapGestureRecognizer = {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapHandel(_:)))
        singleTap.delegate = self
//        singleTap.delaysTouchesBegan = true
//        singleTap.delaysTouchesEnded = true
//        singleTap.numberOfTouchesRequired = 1
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTap)
        return singleTap
    }()
    
    lazy var doubleTap: UITapGestureRecognizer = {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandel(_:)))
        doubleTap.delegate = self
        doubleTap.numberOfTapsRequired = 2
        return doubleTap
    }()
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandel(_:)))
        panGesture.delegate = self
        return panGesture
    }()
    
    func addGesture(to view: UIView) {
        target = view
        guard let target = target else { return }
        target.addGestureRecognizer(singleTap)
        target.addGestureRecognizer(doubleTap)
//        target.addGestureRecognizer(panGesture)
    }
    
    func removeGesture(from view: UIView) {
        guard let target = target else { return }
        target.removeGestureRecognizer(singleTap)
    }
}

extension VDPlayerGestureControl {
    @objc private func singleTapHandel(_ tap: UITapGestureRecognizer) {
        delegate?.vd_playerGestureControlSingleTaped()
    }
    
    @objc private func doubleTapHandel(_ tap: UITapGestureRecognizer) {
        delegate?.vd_playerGestureControlDoubleTaped()
    }
    
    @objc private func panGestureHandel(_ pan: UIPanGestureRecognizer) {
        delegate?.vd_playerGestureControlPan(pan)
    }
}

extension VDPlayerGestureControl: UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//
//    }
}
