//
//  VDPlayer.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class VDPlayer: NSObject {
    
    var isFullScreen: Bool = false
    
    var containerView: UIView? {
        didSet {
            guard let containerView = containerView else { return }
            containerView.addSubview(self.currentPlayerControl.playerView)
        }
    }
    
    var controlView: (UIView & VDPlayerControlProtocol)!
    
    var currentPlayerControl: VDPlayerPlayBackControl! {
        didSet {
            if oldValue?.isPreparedToPlay ?? false {
                oldValue?.stop()
                oldValue?.playerView.removeFromSuperview()
            }
            guard let currentPlayerControl = currentPlayerControl else { return }
            if let containerView = self.containerView {
                containerView.insertSubview(currentPlayerControl.playerView, at: 1)
                currentPlayerControl.playerView.frame = containerView.bounds
                currentPlayerControl.playbackStateDidChanged = { player, state in
                    
                }
                currentPlayerControl.playerPrepareToPlay = { player, assetURL in
                    self.controlView = VDLandScapeControlView(frame: containerView.bounds)
                    self.controlView.player = self
                    currentPlayerControl.playerView.addSubview(self.controlView)
                }
            }
            
        }
    }
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
    
    convenience init(playerControl: VDPlayerPlayBackControl, container: UIView) {
        self.init()
        self.controlView = VDLandScapeControlView()
        self.containerView = container
        self.currentPlayerControl = playerControl
        if let containerView = self.containerView {
//            containerView.addSubview(self.currentPlayerControl.playerView)
            containerView.insertSubview(self.currentPlayerControl.playerView, at: 1)
            currentPlayerControl.playerView.frame = containerView.bounds
            currentPlayerControl.playbackStateDidChanged = { player, state in
                if state == .playing {
                    self.controlView = VDLandScapeControlView(frame: containerView.bounds)
                    self.controlView.player = self
                    self.currentPlayerControl.playerView.addSubview(self.controlView)
                }
            }
            currentPlayerControl.playerPrepareToPlay = { player, assetURL in
                
            }
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
