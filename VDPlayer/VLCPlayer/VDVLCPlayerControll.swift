//
//  VDVLCPlayerControl.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class VDVLCPlayerControl: NSObject, VDPlayerPlayBackProtocol {
    var playbackStateDidChanged: ((VDPlayerPlayBackProtocol, VDPlayerPlaybackState) -> ())?
    var loadStateDidChanged: ((VDPlayerPlayBackProtocol, VDPlayerLoadState) -> ())?
    var playerReadyToPlay: ((VDPlayerPlayBackProtocol, URL) -> ())?
    var playerPrepareToPlay: ((VDPlayerPlayBackProtocol, URL) -> ())?
    var mediaPlayerTimeChanged: ((VDPlayerPlayBackProtocol, TimeInterval, TimeInterval) -> ())?
    
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
    
    var currentTime : TimeInterval          { get { return TimeInterval((player?.time.value.doubleValue ?? 0) / 1000) } }
    var totalTime   : TimeInterval          { get { return TimeInterval(((player?.time.value.doubleValue ?? 0) + fabs(player?.remainingTime.value?.doubleValue ?? 0)) / 1000) } }
    var bufferTime  : TimeInterval          = 0.0
    var seekTime    : TimeInterval          = 0.0
    
    var isPlaying   : Bool                  = false
    var isPreparedToPlay : Bool             = false
    var playState   : VDPlayerPlaybackState = .stopped {
        didSet {
            playbackStateDidChanged?(self, playState)
        }
    }
    var loadState   : VDPlayerLoadState     = .unknow {
        didSet {
            loadStateDidChanged?(self, loadState)
        }
    }
    var scalingMode : VDPlayerScalingMode   = .aspectFit
    var rate        : Float                 { get { return player?.rate ?? 0 } }
    
    var assetURL    : URL? {
        didSet {
//            guard let assetURL = assetURL else { return }
            if player != nil { player?.stop() }
//            let media = VLCMedia(url: assetURL)
//            player?.media = media
            prepareToPlay()
        }
    }
    
    private var cancelBufferingWorkItem: DispatchWorkItem?
    
    override init() {
        super.init()
    }
    
    func initPlayer() {
        guard let assetURL = assetURL else { return }
        let media = VLCMedia(url: assetURL)
        media.delegate = self
        player = VLCMediaPlayer()
        player?.rate = 1.0
        player?.delegate = self
        player?.media = media
        player?.drawable = self.playerView.mediaContainer
    }
    
    private func setupPlayerObserver() {
        
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
        if !isPreparedToPlay {
            prepareToPlay()
        }
        else {
            player?.play()
            isPlaying = true
            playState = .playing
        }
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
        playState = .stopped
        loadState = .unknow
    }
    
    func seek(to time: TimeInterval?, completionHandler: ((Bool) -> ())?) {
        guard let time = time, time is TimeInterval else { return }
        player?.time = VLCTime(int: Int32(time * 1000))
        if let completionHandler = completionHandler {
            completionHandler(true)
        }
    }
    
    func changeRate(_ rate: Float, completionHandler: ((Bool) -> ())?) {
        player?.rate = rate
        completionHandler?(true)
    }
}

extension VDVLCPlayerControl: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        guard let player = aNotification.object as? VLCMediaPlayer else { return }
        switch player.state {
        case .stopped:
            print("stopped")
            playState = .stopped
            loadState = .unknow
            isPreparedToPlay = false
        case .opening:
            print("opening")
            loadState = .prepare
        case .buffering:
            print("buffering, player state:\(player.isPlaying)")
//            if player.isPlaying { loadState = .playable }
//            else { loadState = .prepare }
            loadState = .prepare
            if let cancelBufferingWorkItem = cancelBufferingWorkItem {
                cancelBufferingWorkItem.cancel()
                self.cancelBufferingWorkItem = nil
            }
            cancelBufferingWorkItem = DispatchWorkItem {
                self.loadState = .playable
                print(player.state.rawValue)
            }
            guard let cancelBufferingWorkItem = cancelBufferingWorkItem else { return }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: cancelBufferingWorkItem)
        case .ended:
            print("ended")
        case .playing:
            print("playing")
            playState = .playing
            loadState = .playable
        case .error:
            print("error")
            playState = .error
            loadState = .unknow
            isPreparedToPlay = false
        case .paused:
            print("paused")
            playState = .pause
        case .esAdded:///< Elementary Stream added
            print("esAdded")
//            playState = .unknow
//            loadState = .prepare
            if let assetURL = assetURL { playerReadyToPlay?(self, assetURL) }
        }
//        if let playbackStateDidChanged = playbackStateDidChanged { playbackStateDidChanged(self, playState) }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        guard let player = aNotification.object as? VLCMediaPlayer else { return }
//        print("\(player), \(TimeInterval(player.time.value.doubleValue ?? 0)), \(TimeInterval(fabs(player.remainingTime.value?.doubleValue ?? 0)))")
        if let mediaPlayerTimeChanged = mediaPlayerTimeChanged {
            mediaPlayerTimeChanged(self, TimeInterval(player.time.value.doubleValue / 1000),
                                   TimeInterval((player.time.value.doubleValue + fabs(player.remainingTime.value?.doubleValue ?? 1)) / 1000))
        }
    }
    
    func mediaPlayerChapterChanged(_ aNotification: Notification!) {
        print("mediaPlayerChapterChanged")
    }
}

extension VDVLCPlayerControl: VLCMediaDelegate {
    func mediaDidFinishParsing(_ aMedia: VLCMedia) {
        print("mediaDidFinishParsing")
    }
    
    func mediaMetaDataDidChange(_ aMedia: VLCMedia) {
        print("mediaMetaDataDidChange")
    }
}
