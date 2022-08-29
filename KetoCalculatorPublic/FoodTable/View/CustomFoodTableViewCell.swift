//
//  CustomFoodTableViewCell.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/31.
//

import UIKit

class CustomFoodTableViewCell: UITableViewCell {
    @IBOutlet private weak var foodNameLabel: UILabel!
    @IBOutlet private weak var subFoodNameLabel: UILabel!
    @IBOutlet private weak var ketogenicTypeValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func regularExpression(in text: String) {
    }

    func configuraLabel(for foodName: String, subName: String?, ketogenicTypefigure: Double) {
        foodNameLabel.text = foodName
        if let subName = subName {
            subFoodNameLabel.text = subName
        }
        let figure =  String(ketogenicTypefigure) ?? "0"
        ketogenicTypeValueLabel.text = figure
    }
}
