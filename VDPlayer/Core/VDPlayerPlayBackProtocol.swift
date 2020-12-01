//
//  VDPlayerPlayBackProtocol.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import Foundation
@objc enum VDPlayerPlaybackState: Int {
    case unknow
    case stopped
    case playing
    case pause
    case error
    case faild
}

@objc enum VDPlayerLoadState: Int {
    case unknow
    case prepare
    case playable
    case stalled
}

@objc enum VDPlayerScalingMode: Int {
    case none
    case aspectFit
    case aspectFill
    case fill
}

@objc protocol VDPlayerPlayBackProtocol: NSObjectProtocol {
    var view: VDPlayerView { get set }
    
    /// time
    var currentTime: TimeInterval { get }
    var totalTime: TimeInterval { get }
    var bufferTime: TimeInterval { get set }
    var seekTime: TimeInterval { get set }
    
    /// status
    var isPlaying: Bool { get }
    var isPreparedToPlay: Bool { get }
    var playState: VDPlayerPlaybackState { get }
    var loadState: VDPlayerLoadState { get }
    var rate: Float { get }
    
    /// info
    var scalingMode: VDPlayerScalingMode { get }
    var assetURL: URL? { get set }
    
    /// Handle
    var playbackStateDidChanged: ((VDPlayerPlayBackProtocol, VDPlayerPlaybackState) -> ())? { get set }
    var loadStateDidChanged: ((VDPlayerPlayBackProtocol, VDPlayerLoadState) -> ())? { get set }
    var playerReadyToPlay: ((VDPlayerPlayBackProtocol, URL) -> ())? { get set}
    var playerPrepareToPlay: ((VDPlayerPlayBackProtocol, URL) -> ())? { get set}
    var mediaPlayerTimeChanged: ((VDPlayerPlayBackProtocol, TimeInterval, TimeInterval) -> ())? { get set }
    
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
    
    /// chagne current play rate
    func changeRate(_ rate: Float, completionHandler:((_ finished: Bool)->())?)
}

extension VDPlayerPlayBackProtocol {
    func changeRate(_ rate: Float, completionHandler:((_ finished: Bool)->())?) {}
}
