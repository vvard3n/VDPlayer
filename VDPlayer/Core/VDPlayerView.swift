//
//  VDPlayerView.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

class VDPlayerView: UIView {

    /// 媒体渲染容器
    var mediaContainer: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        mediaContainer = UIView()
        addSubview(mediaContainer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mediaContainer.frame = bounds
        print(mediaContainer.frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
