//
//  DetailFromContainerViewController.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/29.
//

import UIKit

class DetailFromContainerViewController: UIViewController {
    var selectFood: FoodObject?
    var selectFoodTable: SelectFoodTable?

    @IBOutlet private weak var copyBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        copyBarButton.target = self
        copyBarButton.action = #selector(copyDetail)
        copyBarButton.customView?.isHidden = true

        if let foodDetailVC = self.children[0] as? FoodDetailViewContainer {
            foodDetailVC.selectFood = selectFood
        }
    }
}

extension DetailFromContainerViewController {
    @objc func copyDetail() {
        guard let selectFood = selectFood else { return }
        let ratioString = String(format: "%.2f", selectFood.calculateKetogenicValue(in: .ketogenicRatio) ?? 0)
        let indexString = String(format: "%.2f", selectFood.calculateKetogenicValue(in: .ketogenicIndex) ?? 0)
        let valueString = String(format: "%.2f", selectFood.calculateKetogenicValue(in: .ketogenicValue) ?? 0)

        let waterString = String(format: "%.1f", selectFood.water)
        let proteinString = String(format: "%.1f", selectFood.protein)
        let lipidString = String(format: "%.1f", selectFood.lipid)
        let carbohydrateString = String(format: "%.1f", selectFood.carbohydrate)
        let dietaryFiberString = String(format: "%.1f", selectFood.totalDietaryFiber)

        var copyText = """
            食品番号　：\(selectFood.foodCode)
            食品名　　：\(selectFood.name)
            カテゴリ　：\(selectFood.category.name)
            ----------------------------------
            ケトン比　：\(ratioString)
            ケトン指数：\(indexString)
            ケトン値　：\(valueString)
            ----------------------------------
            水分　　　：\(waterString) g
            エネルギー：\(selectFood.energy) kcal
            たんぱく質：\(proteinString) g
            脂質　　　：\(lipidString) g
            炭水化物　：\(carbohydrateString) g
            食物繊維　：\(dietaryFiberString) g
            """

        // レシピに特別なコードを0とする
        if selectFood.foodCode == 0 {
            var ingredientList = String()
            selectFoodTable?
                .list
                .forEach { food in
                    let ingredientString = "\(food.name)： \(food.weight.value)\n"
                    ingredientList.append(ingredientString)
                }

            if !ingredientList.isEmpty {
                let introductionString = """
                    \n----------------------------------
                    【材料一覧】\n
                    """
                let recipeString = introductionString + ingredientList
                copyText.append(recipeString)
            }
        }

        UIPasteboard.general.string = copyText
    }
}
