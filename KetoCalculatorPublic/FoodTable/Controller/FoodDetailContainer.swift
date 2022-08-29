//
//  FoodDetailContainerViewController.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/28.
//

import UIKit

class FoodDetailContainer: UIViewController {
    var selectFood: FoodObject?
    var notificationCenter: NotificationCenter?

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self,
                               forCellReuseIdentifier: "DetailCell")
            tableView.register(
                UINib(nibName: "WeightSetTableViewCell", bundle: nil),
                forCellReuseIdentifier: "WeightSetTableViewCell"
            )
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false

        notificationCenter?
            .addObserver(
                self,
                selector: #selector(weightTextFieldDidChanged),
                name: .weightChange,
                object: nil
            )

//        if let selectFoodTableVC = presentedViewController as? SelectFoodTableViewCotroller {
//            selectFoodTable = selectFoodTableVC.selectFoodTable
//        }
    }

    func configure(selectFood: FoodObject?, notification: NotificationCenter?) {
        self.selectFood = selectFood
        self.notificationCenter = notification
    }

    @objc func weightTextFieldDidChanged(notification: Notification) {
        guard let weightValue = notification.object as? Double,
              let weight = Weight(value: weightValue) else {
                  return
              }

        self.selectFood = selectFood?.changed(in: weight)
        tableView.reloadData()
        self.viewDidLayoutSubviews()
    }
}

extension FoodDetailContainer: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Header.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Header.allCases[section].name
    }

    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Header.allCases[section].numberOfProperty
    }
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let selectFood = selectFood else { fatalError() }
        let cellTitleText = compositionNameString(in: selectFood, indexPath: indexPath)
        let valueString = compositionValueString(in: selectFood, indexPath: indexPath)

        let header = Header.identify(in: indexPath)
        switch header {
        case .userSetting:
            let identifier = "WeightSetTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? WeightSetTableViewCell else {
                fatalError()
            }

            let weight = selectFood.weight
            cell.configure(text: cellTitleText, weight: weight)
            cell.notificationCenter = self.notificationCenter
            return cell

        case .ketone, .nutrients:
            guard let cell = tableView
                    .dequeueReusableCell(withIdentifier: "DetailCell") else { fatalError() }
            var content = UIListContentConfiguration.valueCell()
            content.text = cellTitleText
            content.secondaryText = valueString
            content.secondaryTextProperties.font = UIFont(name: "Helvetica",
                                                          size: content.textProperties.font.pointSize)!
            content.textProperties.numberOfLines = 2
            cell.contentConfiguration = content
            // コードがちょっとおかしい
            cell.backgroundColor = KetogenicGrade.zero
            return cell
        }
    }

    func compositionNameString(in food: FoodObject, indexPath: IndexPath) -> String {
        let text: String
        let header = Header.allCases[indexPath.section]
        switch header {
        case .userSetting:
            text = "重量"
        case .ketone:
            let result
            = KetogenicIndexType
                .allCases[indexPath.row]
                .name
            text = String(describing: result)
        case .nutrients:
            text
            = FoodCompositionType
                .allCases[indexPath.row]
                .name
        }
        return text
    }

    func compositionValueString(in food: FoodObject, indexPath: IndexPath) -> String {
        let text: String
        let header = Header.allCases[indexPath.section]

        switch header {
        case .userSetting:
            text = FoodCompositionType.weight.getCompositionValueString(in: food)
        case .ketone:
            let result: Double
            do {
                result
                = try KetogenicIndexType
                    .allCases[indexPath.row]
                    .calculate(in: food)
                return String(format: "%.2f", result)
            } catch {
                return "計算不可"
            }

        case .nutrients:
            text
            = FoodCompositionType
                .allCases[indexPath.row]
                .getCompositionValueString(in: food)
        }
        return text
    }
}
