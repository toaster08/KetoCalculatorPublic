//
//  UIView+Arrange.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/25.
//

import Foundation
import UIKit

extension CALayer {
    func setupRectangle(cornerRadius: CGFloat = 10,
                        borderColor: UIColor? = .white,
                        shadowOffset: CGSize = CGSize(width: 0, height: 2),
                        shadowColor: UIColor = .black,
                        shadowOpacity: Float = 0.3,
                        shadowRadius: CGFloat? = 3) {
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor?.cgColor
        self.setShadow(offset: shadowOffset,
                       color: shadowColor,
                       opacity: shadowOpacity,
                       radius: shadowRadius)
    }

    func setupCircle(to view: UIView,
                     opacity: Float?,
                     borderColor: UIColor? = .white,
                     shadowOffset: CGSize = CGSize(width: 0, height: 2),
                     shadowColor: UIColor = .black,
                     shadowOpacity: Float = 0.3,
                     shadowRadius: CGFloat? = 3) {
        let cornerRadius = view.bounds.width / 2
        self.cornerRadius = cornerRadius
        if let opacity = opacity {
            self.opacity = opacity
        }

        self.borderColor = borderColor?.cgColor
        self.setShadow(offset: shadowOffset,
                       color: shadowColor,
                       opacity: shadowOpacity,
                       radius: shadowRadius)
    }

    func setShadow(offset: CGSize, color: UIColor, opacity: Float, radius: CGFloat?) {
        self.shadowOffset = offset
        self.shadowColor = color.cgColor
        self.shadowOpacity = opacity
        if let radius = radius {
            self.shadowRadius = radius
        }
    }
}
