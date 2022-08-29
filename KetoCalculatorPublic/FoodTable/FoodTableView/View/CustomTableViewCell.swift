//
//  CustomTableViewCell.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/08/02.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    // 正規表現
    let regex = #"[\［].*\］\s|[\（].*\）\s|[\＜].*\＞\s"#

    @IBOutlet private weak var foodNameLabel: UILabel!
    @IBOutlet private weak var foodSubGroupLabel: UILabel!
    @IBOutlet private weak var foodFigureLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(for food: FoodObject, figure: Double?, in ketogenicType: KetogenicIndexType) {
        let foodKetoneValueColor = food.calculateKetogenicValue(in: ketogenicType) ?? 0
        let foodName = food.name

        let mainFoodName = foodName.replaceFoodName(in: regex)
        foodNameLabel.text = mainFoodName

        let subGroupString = foodName.match(regex)
        foodSubGroupLabel.text = nil

        changeCircleImage(in: food.favorite)

        if subGroupString.isEmpty {
            foodSubGroupLabel.isHidden = true
            foodSubGroupLabel.text = subGroupString
        } else {
            foodSubGroupLabel.isHidden = false
            foodSubGroupLabel.text = subGroupString
        }

        if let figure = figure {
            foodFigureLabel.text = String(format: "%.2f", figure)
        } else {
            foodFigureLabel.text = "不可"
        }

        let ketogenicColor = KetogenicGrade.grade(for: foodKetoneValueColor)
        self.backgroundColor = ketogenicColor

        let cellSelectedBgView = UIView()
        cellSelectedBgView.backgroundColor = UIColor(named: "Cell Select Color")
        self.selectedBackgroundView = cellSelectedBgView
    }

    func configureCell(for food: FoodObject) {
        let foodName = food.name

        let mainFoodName = foodName.replaceFoodName(in: regex)
        foodNameLabel.text = mainFoodName

        let subGroupString = foodName.match(regex)
        foodSubGroupLabel.text = nil

        changeCircleImage(in: food.favorite)

        if subGroupString.isEmpty {
            foodSubGroupLabel.isHidden = true
            foodSubGroupLabel.text = subGroupString
        } else {
            foodSubGroupLabel.isHidden = false
            foodSubGroupLabel.text = subGroupString
        }

        let foodWeight = food.weight.value
        foodFigureLabel.text = String(format: "%.1f", foodWeight)

        let cellSelectedBgView = UIView()
        cellSelectedBgView.backgroundColor = UIColor(named: "Cell Select Color")
        self.selectedBackgroundView = cellSelectedBgView
    }

    func setupSelectTableColor() {
        foodNameLabel.textColor = UIColor(named: "Recipe Cell Color")
        foodSubGroupLabel.textColor = UIColor(named: "Recipe Cell Color")
        foodFigureLabel.textColor = UIColor(named: "Recipe Cell Color")
        self.backgroundColor = UIColor(named: "SelectFoodTable Color")!
    }

    func changeCircleImage(in favorite: Bool) {
        if favorite {
            favoriteButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            favoriteButton.configuration?.baseForegroundColor = UIColor(named: "Gradient3")
        }

        if !favorite {
            favoriteButton.setImage(UIImage(systemName: "circle"), for: .normal)
            favoriteButton.configuration?.baseForegroundColor = UIColor.lightGray
        }
    }
}

extension String {
    func replaceFoodName(in pattern: String) -> String {
        return replacingOccurrences(
            of: pattern,
            with: "",
            options: .regularExpression,
            range: self.range(of: self))
    }

    func match(_ pattern: String) -> String {
        guard let regex
                = try? NSRegularExpression(pattern: pattern) else {
                    return ""
                }

        let results = regex.matches(in: self,
                                    range: NSRange(location: 0,
                                                   length: self.count))

        var textStrings: String = ""
        for resultText in results {
            for res in 0..<resultText.numberOfRanges {
                let start = self.index(self.startIndex,
                                       offsetBy: resultText.range(at: res).location)
                let end = self.index(start,
                                     offsetBy: resultText.range(at: res).length)
                let text = String(self[start..<end])
                textStrings += text
            }
        }
        return textStrings
    }
}
