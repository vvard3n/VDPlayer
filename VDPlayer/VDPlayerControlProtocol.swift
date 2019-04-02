//
//  VDPlayerControlProtocol.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import Foundation
enum VDPlayerPlaybackState {
    case unknow
    case stoped
    case playing
    case pause
    case error
}

enum VDPlayerLoadState {
    case unknow
    case prepare
}

enum VDPlayerScalingMode {
    case none
    case aspectFit
    case aspectFill
    case fill
}

protocol VDPlayerControlProtocol: NSObjectProtocol {
    var playerView: VDPlayerView { get set }
    
    /// time
    var currentTime: TimeInterval { get set }
    var totalTime: TimeInterval { get set }
    var bufferTime: TimeInterval { get set }
    var seekTime: TimeInterval { get set }
    
    /// status
    var isPlaying: Bool { get }
    var isPreparedToPlay: Bool { get }
    var playState: VDPlayerPlaybackState { get }
    var loadState: VDPlayerLoadState { get }
    
    /// info
    var scalingMode: VDPlayerScalingMode { get }
    var assetURL: URL? { get }
    
    /// funcs
    
    /// Prepares the current queue for playback, interrupting any active (non-mixible) audio sessions.
    func prepareToPlay()
    
    /// Reload player.
    func reloadPlayer()
    
    /// Play playback.
    func play()
    
    /// Pauses playback.
    func pause()
    
    /// Replay playback.
    func replay()
    
    /// Stop playback.
    func stop()
    
    /// Seek to a specified time
    func seek(to time: TimeInterval, completionHandler:((_ finished: Bool)->())?)
}
