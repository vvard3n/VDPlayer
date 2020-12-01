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
//    var mediaContainer: UIView!
    private var _presentationSize: CGSize = .zero
    public var presentationSize: CGSize {
        set {
            _presentationSize = newValue
        }
        get {
            if _presentationSize.equalTo(.zero) {
                _presentationSize = frame.size
            }
            return _presentationSize
        }
    }
    var playerView: UIView? {
        willSet {
            if playerView != nil {
                playerView?.removeFromSuperview()
                _presentationSize = .zero
            }
        }
        didSet {
            if let playerView = playerView {
                addSubview(playerView)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        playerView = UIView()
        addSubview(playerView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let playerView = playerView {
            playerView.frame = bounds
            print(playerView.frame)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
