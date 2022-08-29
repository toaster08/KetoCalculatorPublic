//
//  HarfModalVIewController.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/27.
//

import Foundation
import UIKit

protocol RecipeInputProtocol: AnyObject {
    func add(food: FoodObject)
}

class SelectFoodTableViewCotroller: UIViewController {
    var currentKetogenicType: KetogenicIndexType?
    var selectFoodTable: SelectFoodTable = .init(list: []) {
        didSet {
            updateKetogenicValueLabel()
        }
    }

    @IBOutlet private weak var ketogenicTypeLabel: UILabel!
    @IBOutlet private weak var ketogenicTypeValueLabel: UILabel!
    @IBOutlet private weak var selectFoodTableView: UITableView!

    @IBOutlet private weak var resetSelectFoodButton: UIButton!
    @IBOutlet private weak var recipeDetailButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        selectFoodTableView.delegate = self
        selectFoodTableView.dataSource = self
        selectFoodTableView
            .register(
                UINib(nibName: "CustomTableViewCell", bundle: nil),
                forCellReuseIdentifier: "CustomTableViewCell"
            )
//        selectFoodTableView.register(UITableViewCell.self, forCellReuseIdentifier: "selectFoodCell")

        recipeDetailButton
            .addTarget(
                self,
                action: #selector(didTappedRecipeDetailButton),
                for: .touchUpInside
            )

        resetSelectFoodButton
            .addTarget(
                self,
                action: #selector(resetSelectFoodTable),
                for: .touchUpInside
            )

        updateKetogenicValueLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        updateKetogenicValueLabel()
    }

    func updateKetogenicValueLabel() {
        guard let currentKetogenicType = currentKetogenicType else {
            print("return")
            return
        }
        let ketogenicTypeValue = selectFoodTable.calculateKetogenicValue(in: currentKetogenicType)
        let valueString = String(format: "%.2f", ketogenicTypeValue ?? "")
        ketogenicTypeLabel.text = currentKetogenicType.name
        ketogenicTypeValueLabel.text = valueString
    }

    func select(ketogenicType: KetogenicIndexType) {
        currentKetogenicType = ketogenicType
    }

    @objc func didTappedRecipeDetailButton() {
        guard let detailFromContainerVC
                = storyboard?
                .instantiateViewController(
                    withIdentifier: "DetailFromContainerViewController"
                ) as? DetailFromContainerViewController  else {
                    return
                }

        detailFromContainerVC.selectFood = selectFoodTable.makeRecipe()
        detailFromContainerVC.selectFoodTable = selectFoodTable
        present(detailFromContainerVC, animated: true, completion: nil)
    }

    @objc func resetSelectFoodTable() {
        let nonSelectedTable = SelectFoodTable(list: [])
        selectFoodTable = nonSelectedTable
        selectFoodTableView.reloadData()
    }
}

extension SelectFoodTableViewCotroller: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectFoodTable = selectFoodTable.removeFromList(at: indexPath)
            self.selectFoodTable = selectFoodTable
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "材料一覧"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectFoodTable.list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell
                = tableView.dequeueReusableCell(
                    withIdentifier: "CustomTableViewCell"
                ) as? CustomTableViewCell else {
                    fatalError()
                }

        let food = selectFoodTable.list[indexPath.row]
        cell.configureCell(for: food)
        cell.setupSelectTableColor()
        return cell
    }
}

extension SelectFoodTableViewCotroller: RecipeInputProtocol {
    func add(food: FoodObject) {
        selectFoodTable = selectFoodTable.appendToList(for: food)
        updateKetogenicValueLabel()

        if selectFoodTable.list.isEmpty {
            recipeDetailButton?.isUserInteractionEnabled = false
        } else {
            recipeDetailButton?.isUserInteractionEnabled = true
        }

        selectFoodTableView?.reloadData()
    }
}
