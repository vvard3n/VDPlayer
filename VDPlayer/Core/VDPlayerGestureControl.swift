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
}

class VDPlayerGestureControl: NSObject {
    weak var delegate: VDPlayerGestureControlDelegate?
    
    weak var target: UIView?
    
    lazy var singleTap: UITapGestureRecognizer = {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapHandel(_:)))
        singleTap.delegate = self
        singleTap.delaysTouchesBegan = true
        singleTap.delaysTouchesEnded = true
        singleTap.numberOfTouchesRequired = 1
        singleTap.numberOfTapsRequired = 1
        return singleTap
    }()
    
    func addGesture(to view: UIView) {
        target = view
        guard let target = target else { return }
        target.addGestureRecognizer(singleTap)
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
}

extension VDPlayerGestureControl: UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//
//    }
}
