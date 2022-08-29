//
//  FoodTableObject.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/21.
//

import Foundation
import SwiftUI

struct FoodTable {
    private(set) var list: [[FoodObject]]

    func groupList() -> [FoodGroup] {
        var array: [FoodGroup] = []
        if !list.isEmpty {
            list.forEach {
                if let category = $0.first?.category {
                    print(category)
                    array.append(category)
                }
            }
        }
        return array
    }

    func foodCount(in group: Int) -> Int {
        let foodCount = list[group].count
        return foodCount
    }

    func groupNumber() -> Int {
        if list.isEmpty {
            return 0
        } else {
            return list.count
        }
    }

    func specifyFood(for indexPath: IndexPath) -> FoodObject {
        let food = list[indexPath.section][indexPath.row]
        return food
    }

    mutating func update(for specifyfood: FoodObject, at indexPath: IndexPath) {
        list[indexPath.section][indexPath.row] = specifyfood
    }

    func getFavoriteList() -> FoodTable {
        print(#function)

        let favoriteFoodList
        = list.compactMap { sectionFoods -> [FoodObject]? in
            let favoriteFoods = sectionFoods.filter { $0.favorite }
            if !favoriteFoods.isEmpty {
                return favoriteFoods
            }
            return nil
        }

        return FoodTable(list: favoriteFoodList)
    }
}

// initializar
extension FoodTable {
    init(foodTable: [[FoodObject]] = []) {
        list = foodTable
    }

    init() async {
        let foodAllList = await FoodTabelRepositoryImpr().loadFoodTable()

        var foodTable: [[FoodObject]] = []
        // KetoneFormulaを先頭に置く
        let ketoneFormulaGroup = [FoodObject.ketoneFormula]
        foodTable.append(ketoneFormulaGroup)

        FoodGroup.allCases.forEach { foodGroup in
            var arraySection: [FoodObject] = []
            foodAllList.forEach { foodObject in
                if foodObject.category == foodGroup {
                    arraySection.append(foodObject)
                }
            }
            foodTable.append(arraySection)
        }

        list = foodTable
    }
}
