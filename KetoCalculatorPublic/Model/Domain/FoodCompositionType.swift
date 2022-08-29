//
//  CompositionType.swift
//  FoodCompositionTables
//
//  Created by 山田　天星 on 2022/05/01.
//

import Foundation

enum FoodCompositionType: CaseIterable {
    case foodCode
    case foodName
    case water
    case energy
    case protein
    case lipid
    case carbohydrate
    case dietaryfiber
    case category
    case weight

    var name: String {
        switch self {
        case .foodCode: return "食品番号"
        case .foodName: return "食品名"
        case .water:  return "水分"
        case .energy: return "エネルギー"
        case .protein: return "たんぱく質"
        case .lipid: return "脂質"
        case .carbohydrate: return "炭水化物"
        case .dietaryfiber: return "食物繊維"
        case .category: return "カテゴリ"
        case .weight: return "重量"
        }
    }

    func getCompositionValueString(in selectFood: FoodObject) -> String {
        let valueString: String
        switch self {
        case .foodCode: valueString = String(selectFood.foodCode)
        case .foodName: valueString = selectFood.name
        case .energy: valueString =  String(selectFood.energy) + " kcal"
        case .water: valueString =  String(format: "%.1f", selectFood.water) + " g"
        case .protein: valueString =  String(format: "%.1f", selectFood.protein) + " g"
        case .lipid: valueString =  String(format: "%.1f", selectFood.lipid) + " g"
        case .carbohydrate: valueString =  String(format: "%.1f", selectFood.carbohydrate) + " g"
        case .dietaryfiber: valueString =  String(format: "%.1f", selectFood.totalDietaryFiber) + " g"
        case .category: valueString = selectFood.category.name
        case .weight: valueString = "(" + String(format: "%.1f", selectFood.weight.value) + " gあたり)"
        }
        return valueString
    }
}

// enum FoodCompositionalValue {
//    case unmeasured
//    case zero
//    case trace
//    case estimated(Double)
//    case estimatedZero
//    case estimatedValue(Double)
//    case measuredValue(Double)
//
//    var amount: Double? {
//        switch self {
//        case .estimated(let amount):
//            return amount
//        case .estimatedValue(let amount):
//            return amount
//        case .measuredValue(let amount):
//            return amount
//        case .unmeasured, .zero, .trace, .estimatedZero:
//            return nil
//        }
//    }
// }
