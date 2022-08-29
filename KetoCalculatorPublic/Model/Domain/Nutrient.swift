//
//  Calculation.swift
//  KetoCalculator
//
//  Created by toaster on 2021/10/30.
//

import Foundation

struct PFC { // Protein Fat Carbohydrate
    var protein: Double
    var fat: Double
    var carbohydrate: Double

    var energy: Double { // Atwaterの係数
        (protein * 4)
      + (fat * 9)
      + (carbohydrate * 4)
    }
    var ketogenicRatio: Double? {  // ケトン比の算出
        if (protein + carbohydrate) == 0 { return nil }
        return fat / (protein + carbohydrate)
    }

    var ketogenicIndex: Double? { // ケトン指数の算出
        if (carbohydrate + 0.1 * fat + 0.58 * protein) == 0 { return nil }
        return (0.9 * fat + 0.46 * protein) / (carbohydrate + 0.1 * fat + 0.58 * protein)
    }

    // 目標ケトン比に対する必要脂質量の過不足
    func lipidRequirementInKetogenicRatio(for targetValue: Double) -> Double? {
       guard let ketogenicRatio = ketogenicRatio else { return nil}
       return (targetValue - ketogenicRatio) * (protein + carbohydrate)
    }

    // 目標ケトン指数に対する必要脂質量の過不足
    func lipidRequirementInKetogenicIndex(for targetValue: Double) -> Double? {
       if ((0.1 * targetValue - 0.9) - fat) == 0 { return nil }
       return (0.46 * protein - targetValue * (carbohydrate + 0.58 * protein)) / ( 0.1 * targetValue - 0.9) - fat
    }
}

struct PFS { // Protein Fat Sugar
    var protein: Double
    var fat: Double
    var sugar: Double
    var energy: Double { // Atwater
        (protein * 4)
      + (fat * 9)
      + (sugar * 4)
    }
    var ketogenicValue: Double? {
        if (sugar + 0.1 * fat + 0.58 * protein) == 0 { return nil }
        return (0.9 * fat + 0.46 * protein) / (sugar + 0.1 * fat + 0.58 * protein)
    }
    // 目標ケトン値に対する必要脂質量の過不足
    func lipidRequirementInKetogenicValue(for targetValue: Double) -> Double? {
        if ((0.1 * targetValue - 0.9) - fat) == 0 { return nil }
      return (0.46 * protein - targetValue * (sugar + 0.58 * protein)) / (0.1 * targetValue - 0.9) - fat
    }
}
