//
//  VDPlayer.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class VDPlayer: NSObject {
    
    var containerView: UIView? {
        didSet {
            guard let containerView = containerView else { return }
            containerView.addSubview(self.currentPlayerControl.playerView)
        }
    }
    
    var controlView: VDPlayerControlView?
//    var config: VDPlayerConfig!
    var currentPlayerControl: VDPlayerControl!
    var assetURLs: [URL]? {
        didSet {
            play()
        }
    }
//    weak var delegate
    
    override private init() {
        super.init()
        let control = VDVLCPlayerControl()
        self.currentPlayerControl = control
    }
    
//    convenience init(config: VDPlayerConfig) {
//        self.init()
//    }
    
    convenience init(playerControl: VDPlayerControl, container: UIView) {
        self.init()
        self.containerView = container
        self.currentPlayerControl = playerControl
        if let containerView = self.containerView {
            containerView.addSubview(self.currentPlayerControl.playerView)
            currentPlayerControl.playerView.frame = containerView.bounds
        }
    }
}

/// control
extension VDPlayer {
    func play() {
        if containerView == nil { return }
        play(index: 0)
    }
    
    func play(index: Int) {
        guard let assetURLs = assetURLs else { return }
        if assetURLs.isEmpty { return }
        if index > assetURLs.count - 1 { return }
        
        currentPlayerControl.assetURL = assetURLs[index]
    }
    
    func playNext() {
        
    }
    
    func playPrevious() {
        
    }
}
