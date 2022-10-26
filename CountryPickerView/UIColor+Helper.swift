//
//  UIColor+Helper.swift
//  CountryPickerView
//
//  Created by Ahmed Amr on 26/10/2022.
//  Copyright © 2022 Kizito Nwose. All rights reserved.
//

import UIKit

extension UIColor {
    /**
     Initializes a new UIColor object with non normalized RGB values (i.e. values in range 0-255)

     - parameter red: The red value of a color between 0 and 255
     - parameter green: The green value of a color, between 0 and 255
     - parameter blue: The blue value of a color, between 0 and 255
     */

    convenience init(redValue red: CGFloat, greenValue green: CGFloat, blueValue blue: CGFloat, alphaValue alpha: CGFloat = 1) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        assert(alpha >= 0 && alpha <= 1, "Invalid alpha component")

        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha )
    }

    convenience init(hex: Int) {
        let (red, green, blue) = (CGFloat((hex >> 16) & 0xFF), CGFloat((hex >> 8) & 0xFF), CGFloat(hex & 0xFF))
        self.init(redValue: red, greenValue: green, blueValue: blue, alphaValue: 1.0)
    }

    convenience init(hex: Int, alpha: CGFloat) {
        let (red, green, blue) = (CGFloat((hex >> 16) & 0xFF), CGFloat((hex >> 8) & 0xFF), CGFloat(hex & 0xFF))
        self.init(redValue: red, greenValue: green, blueValue: blue, alphaValue: alpha)
    }

    /**
     Initalizes a new UIColor object with a given hex color string
     - parameter hex: The hex value of the color, without the alpha channel
     */
    convenience init(hex: String) {
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count != 6) {
            self.init()
            return
        }

        var rgbValue: UInt64 = 0

        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(redValue: CGFloat((rgbValue & 0xFF0000) >> 16), greenValue: CGFloat((rgbValue & 0x00FF00) >> 8), blueValue: CGFloat((rgbValue & 0x0000FF)), alphaValue: 1)
    }

    func toHex() -> String {
        let components = cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        return String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }
}
