//
//  ViewController.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var player: VDPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let assetURLs: [URL] = [URL(string: "https://mpv.videocc.net/cc84e44bdb/8/cc84e44bdbcd2e2996584c3e59f13558_3.mp4")!]
        
        let width = UIScreen.main.bounds.size.width - 20 * 2
        let height = (UIScreen.main.bounds.size.width - 20 * 2) / 16.0 * 9.0
        
        let videoContainer = UIView(frame: CGRect(x: 20, y: 100, width:width, height:height))
        videoContainer.backgroundColor = .black
        view.addSubview(videoContainer)
        
        let config = VDPlayerConfig(playerType: .VLCPlayer)
        config.assetURLs = assetURLs
        config.container = videoContainer
        
        player = VDPlayer(config: config)
    }


}

