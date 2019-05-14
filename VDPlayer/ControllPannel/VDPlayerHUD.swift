//
//  VDPlayerHUD.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/5/14.
//  Copyright © 2019 vvard3n. All rights reserved.
//

import UIKit

class VDPlayerHUD: UIView {
    
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    private var textLabel: UILabel = {
        var textLabel = UILabel()
        textLabel.font = .systemFont(ofSize: 12)
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        return textLabel
    }()
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        NSString(string: textLabel.text ?? "").boundingRect(with: CGSize(, options: <#T##NSStringDrawingOptions#>, attributes: <#T##[NSAttributedString.Key : Any]?#>, context: <#T##NSStringDrawingContext?#>)
//    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
