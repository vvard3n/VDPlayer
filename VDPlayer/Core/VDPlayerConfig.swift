//
//  VDPlayerConfig.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

enum VDPlayerType {
    case IJKPlayer
    case AVPlayer
    case VLCPlayer
}

class VDPlayerConfig: NSObject {
    var playerType: VDPlayerType = .VLCPlayer
    var assetURLs: [URL]?
    var container: UIView?
    
    override init() {
        super.init()
    }
    
    convenience init(playerType: VDPlayerType) {
        self.init()
        self.playerType = playerType
    }
}
