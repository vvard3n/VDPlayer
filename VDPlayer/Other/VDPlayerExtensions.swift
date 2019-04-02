//
//  VDPlayerExtensions.swift
//  VDPlayer
//
//  Created by Harwyn T'an on 2019/4/2.
//  Copyright © 2019年 vvard3n. All rights reserved.
//

import UIKit

/// iPhone设备
let isIPhone = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone ? true : false)
/// iPad设备
let isIPad = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? true : false)
/// iPhoneX,iPhoneXS,iPhoneXR设备
let isIPhoneX = (max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.height) == 812.0 ? true : false)

func isSafeAreaScreen() -> Bool {
    guard let w = UIApplication.shared.delegate?.window as? UIWindow else { return false }
    if #available(iOS 11.0, *) {
        let safeAreaTop = w.safeAreaInsets.top
        return safeAreaTop > 0
    } else {
        return false
    }
}


/// Get safe area bottom
/// if use autolayout can use:
/// if #available(iOS 11.0, *) {
///     make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(0)
/// } else {
///     make.bottom.equalTo(0)
/// }
var SAFE_AREA_BOTTOM : CGFloat { return VDUIManager.shared().safeAreaInset.bottom }

var SAFE_AREA_TOP : CGFloat { return max(VDUIManager.shared().safeAreaInset.top - 20, 0) }

/// Get status bar height
let STATUSBAR_HEIGHT: CGFloat = UIApplication.shared.statusBarFrame.height

let NAVIGATIONBAR_HEIGHT : CGFloat = UIApplication.shared.statusBarFrame.size.height + 44

let TABBAR_HEIGHT : CGFloat = SAFE_AREA_BOTTOM + 49

let SCREEN_WIDTH : CGFloat = UIScreen.main.bounds.size.width

let SCREEN_HEIGHT : CGFloat = UIScreen.main.bounds.size.height

/// Get point from pixel value
///
/// - Parameter pixel: pixel value
/// - Returns: point value
func CGFloatFromPixel(pixel: CGFloat) -> CGFloat {
    return pixel / UIScreen.main.scale
}

extension CGFloat {
    static func from(pixel: CGFloat) -> CGFloat {
        return pixel / UIScreen.main.scale
    }
}

/// Get top viewcontroller
///
/// - Parameter rootVC: root view controlelr
/// - Returns: top vc
func vd_topViewController(_ rootVC: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let tabbarVC = rootVC as? UITabBarController, let selectedVC = tabbarVC.selectedViewController  {
        return vd_topViewController(selectedVC)
    } else if let naviVC = rootVC as? UINavigationController, let visibleVC = naviVC.visibleViewController {
        return vd_topViewController(visibleVC)
    } else if let presentedVC = rootVC?.presentedViewController {
        return vd_topViewController(presentedVC)
    }
    return rootVC
}

extension UIImage {
    public convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }
        
        self.init(cgImage: image)
    }
    
    public convenience init(color: UIColor) {
        self.init(color: color, size: CGSize(width: 1, height: 1))
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue : UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
    //返回随机颜色
    open class var randomColor:UIColor{
        get
        {
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}

extension UIView {
    
    /// 获取截图
    ///
    /// - Parameters:
    ///   - rect: 截图范围，默认为CGRect.zero
    ///   - scale: 图片缩放因子，默认为屏幕缩放因子
    /// - Returns: 截图
    func vd_snapshotImage(_ rect: CGRect = .zero, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        // 获取整个区域图片
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        drawHierarchy(in: frame, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        // 如果不裁剪图片，直接返回整张图片
        if rect.equalTo(.zero) || rect.equalTo(bounds) {
            return image
        }
        // 按照给定的矩形区域进行剪裁
        guard let sourceImageRef = image.cgImage else { return nil }
        let newRect = rect.applying(CGAffineTransform(scaleX: scale, y: scale))
        guard let newImageRef = sourceImageRef.cropping(to: newRect) else { return nil }
        // 将CGImageRef转换成UIImage
        let newImage = UIImage(cgImage: newImageRef, scale: scale, orientation: .up)
        return newImage
    }
}

struct NoticeKey {
    /// 用户登录成功通知
    static let USER_INFO_CHANGE_NOTIFICATION = "USER_INFO_CHANGE_NOTIFICATION"
}

struct ThemeColor {
    /// color F7F8FA
    static let MAIN_BACKGROUND_COLOR_F7F8FA : UIColor = #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9803921569, alpha: 1)
    /// color eeeeee
    static let LIGHT_LINE_COLOR_EEEEEE : UIColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
    /// color FDFBED
    static let LIGHT_GRAY_COLOR_FDFBED : UIColor = #colorLiteral(red: 0.9921568627, green: 0.9843137255, blue: 0.9294117647, alpha: 1)
    
    /// color 1F1D1D
    static let CONTENT_TEXT_COLOR_1F1D1D : UIColor = #colorLiteral(red: 0.1215686275, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
    /// color 333131
    static let CONTENT_TEXT_COLOR_333131 : UIColor = #colorLiteral(red: 0.2, green: 0.1921568627, blue: 0.1921568627, alpha: 1)
    /// color 666060
    static let CONTENT_TEXT_COLOR_666060 : UIColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
    /// color 555555
    static let CONTENT_TEXT_COLOR_555555 : UIColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
    /// color 999090
    static let CONTENT_TEXT_COLOR_999090 : UIColor = #colorLiteral(red: 0.6, green: 0.5647058824, blue: 0.5647058824, alpha: 1)
    
    /// color 0EAE4E
    static let STOCK_DOWN_GREEN_COLOR_0EAE4E : UIColor = #colorLiteral(red: 0.05490196078, green: 0.6823529412, blue: 0.3058823529, alpha: 1)
    /// color E55C5C
    static let STOCK_UP_RED_COLOR_E55C5C : UIColor = #colorLiteral(red: 0.8980392157, green: 0.3607843137, blue: 0.3607843137, alpha: 1)
    
    /// color 3D9CCC
    static let BLUE_COLOR_3D9CCC : UIColor = #colorLiteral(red: 0.2392156863, green: 0.6117647059, blue: 0.8, alpha: 1)
    
    /// color E63130
    static let MAIN_COLOR_E63130 : UIColor = #colorLiteral(red: 0.9019607843, green: 0.1921568627, blue: 0.1882352941, alpha: 1)
    /// color DBDBDB
    static let GRAY_COLOR_DBDBDB : UIColor = #colorLiteral(red: 0.8588235294, green: 0.8588235294, blue: 0.8588235294, alpha: 1)
}

struct ThemeFont {
    static let NAV_TITLE_FONT_SIZE : CGFloat = 18
    static let NAV_TITLE_FONT : UIFont = UIFont.systemFont(ofSize: ThemeFont.NAV_TITLE_FONT_SIZE)
    static let NAV_TITLE_BOLD_FONT : UIFont = UIFont.boldSystemFont(ofSize: ThemeFont.NAV_TITLE_FONT_SIZE)
    static let TIME_TEXT_FONT : UIFont = UIFont.systemFont(ofSize: 12)
}
