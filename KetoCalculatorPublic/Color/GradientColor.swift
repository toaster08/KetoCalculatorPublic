//
//  CalculatorView+Color.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/25.
//

import Foundation
import UIKit

extension CAGradientLayer {
    static func gradientLayer(in frame: CGRect) -> Self {
        let layer = Self()
        layer.colors = colors()
        layer.startPoint = CGPoint.init(x: 0, y: 0)
        layer.endPoint = CGPoint.init(x: 1, y: 1)
        layer.frame = frame
        return layer
    }

    private static func colors() -> [CGColor] {
        let beginColor: UIColor = UIColor(named: "Gradient1")!
        let interColor: UIColor = UIColor(named: "Gradient2")!
        let endColor: UIColor = UIColor(named: "Gradient3")!
        return [beginColor.cgColor, interColor.cgColor, endColor.cgColor]
    }
}
