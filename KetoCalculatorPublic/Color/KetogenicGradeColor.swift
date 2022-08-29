//
//  Color.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/20.
//

import Foundation
import UIKit

enum KetogenicGrade {
    // #colorLiteral( でインスペクタ上で色を得られる
    static let zero = UIColor(named: "FoodTable Cell Mode Color")!
    static let zeroPointFive = UIColor(named: "0.5to1")!
    static let one = UIColor(named: "1.0to1.5")!
    static let onePointFive = UIColor(named: "1.5to2.0")!
    static let two = UIColor(named: "2.0to2.5")!
    static let twoPointFive = UIColor(named: "2.5to3.0")!
    static let three = UIColor(named: "3.0over")!

    static func grade(for value: Double) -> UIColor {
        switch value {
        case 0..<0.5 : return KetogenicGrade.zero
        case 0.5..<1: return KetogenicGrade.zeroPointFive
        case 1..<1.5: return KetogenicGrade.one
        case 1.5..<2: return KetogenicGrade.onePointFive
        case 2..<2.5: return KetogenicGrade.two
        case 2.5..<3: return KetogenicGrade.twoPointFive
        case 3... : return KetogenicGrade.three
        default: fatalError()
        }
    }
}
