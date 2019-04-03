//
//  VDPlayerView.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class VDPlayerView: UIView {

    var mediaContainer: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mediaContainer = UIView()
        addSubview(mediaContainer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mediaContainer.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
