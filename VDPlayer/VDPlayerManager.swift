//
//  VDPlayerManager.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class VDPlayerManager: NSObject {
    var config: VDPlayerConfig!
    
    override private init() {
        super.init()
    }
    
    convenience init(config: VDPlayerConfig) {
        self.init()
        self.config = config
    }
}
