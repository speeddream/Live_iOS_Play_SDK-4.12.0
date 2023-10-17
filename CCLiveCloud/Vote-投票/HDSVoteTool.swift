//
//  HDSVoteTool.swift
//  CCLiveCloud
//
//  Created by 刘强强 on 2022/3/28.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import UIKit

class HDSVoteTool: NSObject {
    @objc static let tool = HDSVoteTool()
    @objc var isLandspace: Bool = false
    
}

func HDS_ConfigRectCorner(view: UIView, corner: UIRectCorner, radii: CGSize) -> CALayer {
      
      let maskPath = UIBezierPath.init(roundedRect: view.bounds, byRoundingCorners: corner, cornerRadii: radii)
      
      let maskLayer = CAShapeLayer.init()
      maskLayer.frame = view.bounds
      maskLayer.path = maskPath.cgPath
      
      return maskLayer
}

extension String {
    /// 十六进制字符串颜色转为UIColor
    /// - Parameter alpha: 透明度
    func uicolor(alpha: CGFloat = 1.0) -> UIColor {
        // 存储转换后的数值
        var red: UInt64 = 0, green: UInt64 = 0, blue: UInt64 = 0
        var hex = self
        // 如果传入的十六进制颜色有前缀，去掉前缀
        if hex.hasPrefix("0x") || hex.hasPrefix("0X") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 2)...])
        } else if hex.hasPrefix("#") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 1)...])
        }
        // 如果传入的字符数量不足6位按照后边都为0处理，当然你也可以进行其它操作
        if hex.count < 6 {
            for _ in 0..<6-hex.count {
                hex += "0"
            }
        }

        // 分别进行转换
        // 红
        Scanner(string: String(hex[..<hex.index(hex.startIndex, offsetBy: 2)])).scanHexInt64(&red)
        // 绿
        Scanner(string: String(hex[hex.index(hex.startIndex, offsetBy: 2)..<hex.index(hex.startIndex, offsetBy: 4)])).scanHexInt64(&green)
        // 蓝
        Scanner(string: String(hex[hex.index(startIndex, offsetBy: 4)...])).scanHexInt64(&blue)

        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
}

/*
 1: '#FE9601', 橙色
 2: '#07C563', 绿色
 3: '#00D1AA',
 4: '#1676FE',
 5: '#6847EE',
 6: '#FF4141',
 7: '#FF6203'
 */
