//
//  VDPlayerControlProtocol.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019 vvard3n. All rights reserved.
//

import UIKit

protocol VDPlayerControlProtocol: NSObjectProtocol {

    var player: VDPlayer! { get set }
    
    func gestureSingleTapped()
    func gestureDoubleTapped()
    func gesturePan(_ panGesture: UIPanGestureRecognizer)
    func playerOrientationWillChanged(player: VDPlayer, observer: VDPlayerOrientationObserver)
    func playerOrientationDidChanged(player: VDPlayer, observer: VDPlayerOrientationObserver)
    
    func updateTime(current: TimeInterval, total: TimeInterval)
    func reset()
}

extension VDPlayerControlProtocol {
    func gestureSingleTapped() {}
    func gestureDoubleTapped() {}
    func gesturePan(_ panGesture: UIPanGestureRecognizer) {}
    func playerOrientationWillChanged(player: VDPlayer, observer: VDPlayerOrientationObserver) {}
    func playerOrientationDidChanged(player: VDPlayer, observer: VDPlayerOrientationObserver) {}
    
    func updateTime(current: TimeInterval, total: TimeInterval) {}
    func reset() {}
}
