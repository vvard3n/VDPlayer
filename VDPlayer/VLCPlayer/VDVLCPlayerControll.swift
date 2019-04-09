//
//  VDVLCPlayerControl.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class VDVLCPlayerControl: NSObject, VDPlayerPlayBackControl {
    
    var playbackStateDidChanged: ((VDPlayerPlayBackControl, VDPlayerPlaybackState) -> ())?
    var playerPrepareToPlay: ((VDPlayerPlayBackControl, URL) -> ())?
    
//    var option: [String : Any] = [kVLCSettingPasscodeAllowFaceID : 1,
//                                  kVLCSettingPasscodeAllowTouchID : 1,
//                                  kVLCSettingContinueAudioInBackgroundKey : true,
//                                  kVLCSettingStretchAudio : false,
//                                  kVLCSettingTextEncoding : kVLCSettingTextEncodingDefaultValue,
//                                  kVLCSettingSkipLoopFilter : 1,
//                                  kVLCSettingSubtitlesFont : kVLCSettingSubtitlesFontDefaultValue,
//                                  kVLCSettingSubtitlesFontColor : kVLCSettingSubtitlesFontColorDefaultValue,
//                                  kVLCSettingSubtitlesFontSize : kVLCSettingSubtitlesFontSizeDefaultValue,
//                                  kVLCSettingSubtitlesBoldFont: false,
//                                  kVLCSettingDeinterlace : 0,
//                                  kVLCSettingHardwareDecoding : kVLCSettingHardwareDecodingDefault,
//                                  kVLCSettingNetworkCaching : 999,
//                                  kVLCSettingVolumeGesture : true,
//                                  kVLCSettingPlayPauseGesture : true,
//                                  kVLCSettingBrightnessGesture : true,
//                                  kVLCSettingSeekGesture : true,
//                                  kVLCSettingCloseGesture : true,
//                                  kVLCSettingVariableJumpDuration : false,
//                                  kVLCSettingVideoFullscreenPlayback : true,
//                                  kVLCSettingContinuePlayback : 1,
//                                  kVLCSettingContinueAudioPlayback : 1,
//                                  kVLCSettingFTPTextEncoding : 5,
//                                  kVLCSettingWiFiSharingIPv6 : false,
//                                  kVLCSettingEqualizerProfile : 0,
//                                  kVLCSettingPlaybackForwardSkipLength : 60,
//                                  kVLCSettingPlaybackBackwardSkipLength : 60,
//                                  kVLCSettingOpenAppForPlayback : true,
//                                  kVLCAutomaticallyPlayNextItem : true]
    
    var player      : VLCMediaPlayer?
    /// 播放器容器（VDPlayerView -> 渲染层 -> ControlView）
    var playerView  : VDPlayerView          = VDPlayerView()
    
    var currentTime : TimeInterval          = 0.0
    var totalTime   : TimeInterval          = 0.0
    var bufferTime  : TimeInterval          = 0.0
    var seekTime    : TimeInterval          = 0.0
    
    var isPlaying   : Bool                  = false
    var isPreparedToPlay : Bool             = false
    var playState   : VDPlayerPlaybackState = .stoped
    var loadState   : VDPlayerLoadState     = .unknow
    var scalingMode : VDPlayerScalingMode   = .aspectFit
    var assetURL    : URL? {
        didSet {
            guard let assetURL = assetURL else { return }
            if player != nil { player?.stop() }
            let media = VLCMedia(url: assetURL)
            player?.media = media
            prepareToPlay()
        }
    }
    
    override init() {
        super.init()
    }
    
    func initPlayer() {
        guard let assetURL = assetURL else { return }
        let media = VLCMedia(url: assetURL)
//        media.delegate = self
        player = VLCMediaPlayer()
        player?.delegate = self
        player?.media = media
        player?.drawable = self.playerView.mediaContainer
    }
    
    func prepareToPlay() {
        if assetURL == nil { return }
        isPreparedToPlay = true
        initPlayer()
        play()
        loadState = .prepare
        if let playerPrepareToPlay = playerPrepareToPlay, let assetURL = assetURL { playerPrepareToPlay(self, assetURL) }
    }
    
    func reloadPlayer() {
        prepareToPlay()
    }
    
    func play() {
        player?.play()
        isPlaying = true
        playState = .playing
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        playState = .pause
    }
    
    func replay() {
        seek(to: 0) { [weak self] (completion) in
            guard let weakSelf = self else { return }
            weakSelf.play()
        }
    }
    
    func stop() {
        player?.stop()
        player = nil
        assetURL = nil
        playState = .stoped
    }
    
    func seek(to time: TimeInterval, completionHandler: ((Bool) -> ())?) {
        player?.time = VLCTime(int: Int32(time))
        if let completionHandler = completionHandler {
            completionHandler(true)
        }
    }
}

extension VDVLCPlayerControl: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        print("\(player!.state.rawValue)")
        guard let player = aNotification.object as? VLCMediaPlayer else { return }
        switch player.state {
        case .opening, .buffering, .stopped, .ended:
            playState = .stoped
        case .playing:
            playState = .playing
        case .error:
            playState = .error
        case .paused:
            playState = .pause
        case .esAdded:///< Elementary Stream added
            playState = .unknow
        }
        if let playbackStateDidChanged = playbackStateDidChanged { playbackStateDidChanged(self, playState) }
    }
    
    
}
