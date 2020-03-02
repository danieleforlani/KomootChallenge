//
//  UIImageHelper.swift
//  AppFoundation
//
//  Created by Daniele Forlani on 06/08/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

    class func circle(diameter: CGFloat,
                      backgroundColor: UIColor,
                      letterColor: UIColor,
                      initial: String,
                      font: UIFont) -> UIImage? {

        guard initial.count > 0 else { return nil }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.saveGState()

        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)

        ctx.setFillColor(backgroundColor.cgColor)
        ctx.fillEllipse(in: rect)

        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center

        let textFontAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.baselineOffset: -1,
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.foregroundColor: letterColor
            ] as [NSAttributedString.Key: Any]
        initial.draw(in: rect, withAttributes: textFontAttributes)

        ctx.restoreGState()
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()

        return img
    }

    public class func avatarImage(initials: String) -> UIImage {
        let color = UIColor.randomColor()
        return circle(diameter: 24,
                      backgroundColor: color,
                      letterColor: color.opposite(),
                      initial: initials,
                      font: UIFont.boldSystemFont(ofSize: 15))
            ?? UIImage()
    }
}

extension UIColor {
    static func iOS7redColor() -> UIColor { return UIColor(red: 1.0, green: 0.22, blue: 0.22, alpha: 1.0) }
    static func iOS7orangeColor() -> UIColor { return UIColor(red: 1.0, green: 0.58, blue: 0.21, alpha: 1.0) }
    static func iOS7yellowColor() -> UIColor { return UIColor(red: 1.0, green: 0.79, blue: 0.28, alpha: 1.0) }
    static func iOS7greenColor() -> UIColor { return UIColor(red: 0.27, green: 0.85, blue: 0.46, alpha: 1.0) }
    static func iOS7lightBlueColor() -> UIColor { return UIColor(red: 0.18, green: 0.67, blue: 0.84, alpha: 1.0) }
    static func iOS7darkBlueColor() -> UIColor { return UIColor(red: 0.0, green: 0.49, blue: 0.96, alpha: 1.0) }
    static func iOS7purpleColor() -> UIColor { return UIColor(red: 0.35, green: 0.35, blue: 0.81, alpha: 1.0) }
    static func iOS7pinkColor() -> UIColor { return UIColor(red: 1.0, green: 0.17, blue: 0.34, alpha: 1.0) }
    static func iOS7darkGrayColor() -> UIColor { return UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1.0) }
    static func iOS7lightGrayColor() -> UIColor { return UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1.0) }

    static func randomColor() -> UIColor {
        return [iOS7redColor(),
                iOS7orangeColor(),
                iOS7yellowColor(),
                iOS7greenColor(),
                iOS7lightBlueColor(),
                iOS7darkBlueColor(),
                iOS7purpleColor(),
                iOS7pinkColor(),
                iOS7darkGrayColor(),
                iOS7lightGrayColor()].randomElement() ?? iOS7redColor()
    }

    func opposite() -> UIColor {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        return UIColor(red: 1.0 - fRed, green: 1.0 - fGreen, blue: 1 - fBlue, alpha: 1.0)
    }
}
