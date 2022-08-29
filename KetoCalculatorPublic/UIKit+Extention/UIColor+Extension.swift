//
//  UIColor+Extension.swift
//  KetoCalculator
//
//  Created by toaster on 2022/02/06.
//

import Foundation
import UIKit

public func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
    if #available(iOS 13, *) {
        return UIColor { traitCollection -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return dark
            } else {
                return light
            }
        }
    }
    return light
}
