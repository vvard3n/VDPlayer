//
//  VDPlayerControlProtocol.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/3.
//  Copyright © 2019 vvard3n. All rights reserved.
//

import UIKit

protocol VDPlayerControlProtocol: NSObjectProtocol {

    var player: VDPlayer! { get set }
    
    func gestureSingleTapped()
}

extension VDPlayerControlProtocol {
    func gestureSingleTapped() {}
}
