//
//  Nutrients.swift
//  FoodCompositionTables
//
//  Created by 山田　天星 on 2022/04/09.
//

import Foundation

enum ErrorType: Error {
    case couldntCaluculate
}

struct Weight: Equatable, CustomStringConvertible {
    let value: Double

    var ratio: Double {
        value / 100
    }

    var description: String { "\(value)" }

    init?(value: Double = 100.0) {
        guard value >= 0 else { return nil }
        self.value = value
    }
}

extension Weight {
    static func + (left: Weight, right: Weight) -> Weight {
        let weight = left.value + right.value
        return Weight(value: weight)!
    }

    static func - (left: Weight, right: Weight) -> Weight {
        let weight = left.value - right.value
        return Weight(value: weight)!
    }
}

// 食品のオブジェクト
struct FoodObject: Equatable {
    struct InitialComposition: Equatable {
        let energy: Int
        let water: Double
        let protein: Double
        let lipid: Double
        let totalDietaryFiber: Double
        let carbohydrate: Double
        let weight = Weight(value: 100)!
    }

    let id: Int
    let foodCode: Int
    let name: String
    let energy: Int
    let water: Double
    let protein: Double
    let lipid: Double
    let totalDietaryFiber: Double
    let carbohydrate: Double
    let category: FoodGroup
    let weight: Weight
    var favorite: Bool

    let initialComposition: InitialComposition

    private var sugar: Double {
        let min: Double = 0
        let sugar = carbohydrate - totalDietaryFiber
        return max(sugar, min)
    }

    private var ketogenicRatio: Double? {  // ケトン比の算出
        if (protein + carbohydrate) == 0 { return nil }
        return lipid / (protein + carbohydrate)
    }

    private var ketogenicIndex: Double? { // ケトン指数の算出
        if (carbohydrate + 0.1 * lipid + 0.58 * protein) == 0 { return nil }
        return (0.9 * lipid + 0.46 * protein) / (carbohydrate + 0.1 * lipid + 0.58 * protein)
    }

    private var ketogenicValue: Double? {
        if (sugar + 0.1 * lipid + 0.58 * protein) == 0 { return nil }
        return (0.9 * lipid + 0.46 * protein) / (sugar + 0.1 * lipid + 0.58 * protein)
    }

    func changed(in weight: Weight) -> FoodObject {
        let changedFoodObject = FoodObject(from: self, in: weight)
        print(changedFoodObject)
        return changedFoodObject
    }

    func calculateKetogenicValue(in ketoneType: KetogenicIndexType) -> Double? {
        switch ketoneType {
        case .ketogenicRatio:
            return ketogenicRatio
        case .ketogenicIndex:
            return ketogenicIndex
        case .ketogenicValue:
            return ketogenicValue
        }
    }
}

// MARK: イニシャライズを拡張することでクラスのメンバワイズイニシャライザが潰されない　＝　メンバワイズが使える
extension FoodObject {
    init(food: FoodComposition) {
        id = food.id!
        foodCode = food.food_code!
        name = food.food_name!
        category = FoodGroup(value: food.category)!
        weight = Weight()!
        energy = food.energy ?? 0
        water = food.water ?? 0
        protein = food.protein ?? 0
        lipid = food.fat ?? 0
        totalDietaryFiber = food.dietaryfiber ?? 0
        carbohydrate = food.carbohydrate ?? 0
        favorite = food.favorite

        initialComposition = InitialComposition(
            energy: energy,
            water: water,
            protein: protein,
            lipid: lipid,
            totalDietaryFiber: totalDietaryFiber,
            carbohydrate: carbohydrate
        )
    }

    init(from foodObject: FoodObject, in weight: Weight) {
        id = foodObject.id
        foodCode = foodObject.foodCode
        name = foodObject.name
        category = foodObject.category
        favorite = foodObject.favorite
        initialComposition = foodObject.initialComposition
        self.weight = weight

        energy = Int(foodObject.changeCompositionalValue(of: .energy, for: weight))
        water = foodObject.changeCompositionalValue(of: .water, for: weight)
        protein = foodObject.changeCompositionalValue(of: .protein, for: weight)
        lipid = foodObject.changeCompositionalValue(of: .lipid, for: weight)
        carbohydrate = foodObject.changeCompositionalValue(of: .carbohydrate, for: weight)
        totalDietaryFiber = foodObject.changeCompositionalValue(of: .dietaryfiber, for: weight)
    }

    private func changeCompositionalValue(of composition: FoodCompositionType, for weight: Weight) -> Double {
        switch composition {
        case .water:
            return self.initialComposition.water * weight.ratio
        case .energy:
            let doubleTypeEnergy = Double(self.initialComposition.energy)
            return doubleTypeEnergy * weight.ratio
        case .protein:
            return self.initialComposition.protein * weight.ratio
        case .lipid:
            return self.initialComposition.lipid * weight.ratio
        case .carbohydrate:
            return self.initialComposition.carbohydrate * weight.ratio
        case .dietaryfiber:
            return self.initialComposition.totalDietaryFiber * weight.ratio
        case .foodCode, .foodName, .category, .weight:
            fatalError()
        }
    }
}

extension FoodObject {
    // 2018年10月時点の成分値　　ケトン食レシピより
    static let ketoneFormula
    = FoodObject(
        id: 81711, // 明治817-Bを10進数と無理やして表記
        foodCode: 81711,
        name: "ケトンフォーミュラ",
        energy: 741,
        water: 2.0,
        protein: 15.0,
        lipid: 71.8,
        totalDietaryFiber: 0,
        carbohydrate: 8.8,
        category: .preparedfoods,
        weight: Weight()!,
        favorite: true,

        initialComposition: InitialComposition(
            energy: 741,
            water: 2.0,
            protein: 15.0,
            lipid: 71.8,
            totalDietaryFiber: 0,
            carbohydrate: 8.8
        )
    )
}
