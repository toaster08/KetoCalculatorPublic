//
//  CompositionDetailViewController.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/19.
//

import UIKit
import Foundation

class FoodDetailViewController: UIViewController {
    weak var recipeInputDelegate: RecipeInputProtocol?

    var selectFood: FoodObject?

    @IBOutlet private weak var addFoodBarButton: UIBarButtonItem!
    @IBOutlet private weak var copyBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        addFoodBarButton.target = self
        addFoodBarButton.action = #selector(didTappedAddFoodBarButton)

        copyBarButton.target = self
        copyBarButton.action = #selector(copyDetail)

        if let foodDetailVC = self.children[0] as? FoodDetailViewContainer {
            foodDetailVC.selectFood = selectFood
        }
    }
}

// MARK: Action
extension FoodDetailViewController {
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

        let copyText = """
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

        UIPasteboard.general.string = copyText
    }

    @objc func didTappedAddFoodBarButton() {
        if let foodDetailVC = self.children[0] as? FoodDetailViewContainer {
            selectFood = foodDetailVC.selectFood
        }

        guard let selectFood = selectFood else { return }
        recipeInputDelegate?.add(food: selectFood)
        navigationController?.popViewController(animated: true)
    }
}
