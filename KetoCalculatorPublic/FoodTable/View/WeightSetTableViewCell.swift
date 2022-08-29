//
//  WeightSetTableViewCell.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/27.
//

import UIKit

extension Notification.Name {
    static let weightChange = Notification.Name("weightChange")
}

class WeightSetTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet private weak var cellTextLabel: UILabel!
    @IBOutlet private weak var weightTextField: UITextField!

    var notificationCenter: NotificationCenter?

    override func awakeFromNib() {
        super.awakeFromNib()
        weightTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(text: String, weight: Weight) {
        cellTextLabel?.text = text
        weightTextField?.text = "\(weight.value)"
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let weightValue = Double(weightTextField.text ?? "") else { return }

        notificationCenter?
            .post(
                name: .weightChange,
                object: weightValue,
                userInfo: nil
            )
    }
}
