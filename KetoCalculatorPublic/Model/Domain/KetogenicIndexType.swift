//
//  KetogenicIndexType.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/21.
//

import Foundation

enum KetogenicIndexType: Int, CaseIterable {
    case ketogenicRatio // ケトン比
    case ketogenicIndex // ケトン指数
    case ketogenicValue // ケトン値

    var name: String {
        switch self {
        case .ketogenicRatio: return "ケトン比"
        case .ketogenicIndex: return "ケトン指数"
        case .ketogenicValue: return "ケトン値"
        }
    }

    func calculate(in food: FoodObject) throws -> Double {
        guard let value = food.calculateKetogenicValue(in: self) else {
            throw ErrorType.couldntCaluculate
        }

        return value
    }
}
