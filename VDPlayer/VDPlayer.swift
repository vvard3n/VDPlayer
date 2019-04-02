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
    var config: VDPlayerConfig?
//    weak var delegate
    
    init(playWithURL: URL, container: UIView) {
        super.init()
    }
}
