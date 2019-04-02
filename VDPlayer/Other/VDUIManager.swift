//
//  VDUIManager.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

@objcMembers
class VDUIManager: NSObject {
    var safeAreaInset: UIEdgeInsets {
        get {
            if #available(iOS 11.0, *) {
                return UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets.zero
            } else {
                return UIEdgeInsets.zero
            }
        }
    }
    
    public static let manager = VDUIManager()
    
    open class func shared() -> VDUIManager {
        return VDUIManager.manager
    }
}
