//
//  VDPlayer.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class VDPlayer: NSObject {
    
    var containerView: UIView = UIView()
    var controlView: VDPlayerControlView?
    var config: VDPlayerConfig!
    var currentPlayerControl: VDPlayerControl!
//    weak var delegate
    
    override private init() {
        super.init()
        config = VDPlayerConfig()
    }
    
    convenience init(config: VDPlayerConfig) {
        self.init()
        self.config = config
        switch config.playerType {
        case .VLCPlayer:
            let control = VDVLCPlayerControl()
            self.currentPlayerControl = control
            break
        default:
            break
        }
        
        if let superview = config.container {
            superview.addSubview(self.currentPlayerControl.playerView)
            currentPlayerControl.playerView.frame = superview.bounds
        }
        play()
    }
}

/// control
extension VDPlayer {
    func play() {
        if config == nil { return }
        play(index: 0)
    }
    
    func play(index: Int) {
        guard let assetURLs = config.assetURLs else { return }
        if assetURLs.isEmpty { return }
        if index > assetURLs.count - 1 { return }
        
        currentPlayerControl.assetURL = assetURLs[index]
    }
    
    func playNext() {
        
    }
    
    func playPrevious() {
        
    }
}
