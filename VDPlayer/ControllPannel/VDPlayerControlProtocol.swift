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
    
    func hideControlView(animated: Bool)
    func gestureSingleTapped()
    func gestureDoubleTapped()
    func gesturePan(_ panGesture: UIPanGestureRecognizer)
    func playerOrientationWillChanged(player: VDPlayer, observer: VDPlayerOrientationObserver)
    func playerOrientationDidChanged(player: VDPlayer, observer: VDPlayerOrientationObserver)
    func playerPlayStateChanged(player: VDPlayer, playState: VDPlayerPlaybackState)
    func playerLoadStateChanged(player: VDPlayer, loadState: VDPlayerLoadState)
    func playerPrepareToPlay(player: VDPlayer)
    
    func updateTime(current: TimeInterval, total: TimeInterval)
    func reset()
}

extension VDPlayerControlProtocol {
    
    func hideControlView(animated: Bool) {}
    func gestureSingleTapped() {}
    func gestureDoubleTapped() {}
    func gesturePan(_ panGesture: UIPanGestureRecognizer) {}
    func playerOrientationWillChanged(player: VDPlayer, observer: VDPlayerOrientationObserver) {}
    func playerOrientationDidChanged(player: VDPlayer, observer: VDPlayerOrientationObserver) {}
    func playerPlayStateChanged(player: VDPlayer, playState: VDPlayerPlaybackState) {}
    func playerLoadStateChanged(player: VDPlayer, loadState: VDPlayerLoadState) {}
    func playerPrepareToPlay(player: VDPlayer) {}
    
    func updateTime(current: TimeInterval, total: TimeInterval) {}
    func reset() {}
}
