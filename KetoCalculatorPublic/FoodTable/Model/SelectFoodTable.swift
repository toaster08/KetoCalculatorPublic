//
//  SelectFoodTable.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/27.
//

import Foundation

struct SelectFoodTable {
    let list: [FoodObject]

    var recipe: FoodObject {
       let recipe = makeRecipe()
       return recipe
    }

    let recipeID = 0
    let recipeCode = 0
    let recipeName = "レシピ"
    // Value
    var totalWater: Double { list.reduce(0) { $0 + $1.water } }
    var totalEnergy: Int { list.reduce(0) { $0 + $1.energy } }
    var totalProtein: Double { list.reduce(0) { $0 + $1.protein} }
    var totalLipid: Double { list.reduce(0) { $0 + $1.lipid} }
    var totalCarbohydrate: Double { list.reduce(0) { $0 + $1.carbohydrate} }
    var totalDietaryFiber: Double { list.reduce(0) { $0 + $1.totalDietaryFiber} }
    var totalWeight: Weight { list.reduce(Weight(value: 0)!) { $0 + $1.weight } }

    func calculateComposition(per weight: Weight) -> FoodObject.InitialComposition {
        let water = totalWater / totalWeight.ratio

        var energyDouble = (Double(totalEnergy) / totalWeight.ratio)
        if energyDouble.isInfinite || energyDouble.isNaN { energyDouble = 0 }
        let energy = Int(energyDouble)

        let protein = totalProtein / totalWeight.ratio
        let lipid = totalLipid / totalWeight.ratio
        let carbohydrate = totalCarbohydrate / totalWeight.ratio
        let dietaryFiber = totalDietaryFiber / totalWeight.ratio

        let composition = FoodObject
            .InitialComposition(
                energy: energy,
                water: water,
                protein: protein,
                lipid: lipid,
                totalDietaryFiber: dietaryFiber,
                carbohydrate: carbohydrate
            )
        return composition
    }

    func makeRecipe() -> FoodObject {
        let foodObject = FoodObject(id: recipeID,
                                    foodCode: recipeCode,
                                    name: recipeName,
                                    energy: totalEnergy,
                                    water: totalWater,
                                    protein: totalProtein,
                                    lipid: totalLipid,
                                    totalDietaryFiber: totalDietaryFiber,
                                    carbohydrate: totalCarbohydrate,
                                    category: .preparedfoods,
                                    weight: totalWeight,
                                    favorite: false,
                                    initialComposition: calculateComposition(per: totalWeight))
        return foodObject
    }

    func appendToList(for food: FoodObject) -> SelectFoodTable {
        var newList = list
        newList.append(food)
        return SelectFoodTable(list: newList)
    }

    func removeFromList(at indexPath: IndexPath) -> SelectFoodTable {
        var newList = list
        newList.remove(at: indexPath.row)
        return SelectFoodTable(list: newList)
    }

    func calculateKetogenicValue(in ketogenicType: KetogenicIndexType) -> Double? {
        let recipe = makeRecipe()
        return recipe.calculateKetogenicValue(in: ketogenicType)
    }

    func calculateCompositionValueString(in composition: FoodCompositionType) -> String? {
        composition.getCompositionValueString(in: recipe)
    }
}
