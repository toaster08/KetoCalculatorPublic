//
//  Errors.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/08/09.
//

import UIKit

extension UIAlertController {
    class func errorAlert(message: String) -> UIAlertController {
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return errorAlert
    }
}
