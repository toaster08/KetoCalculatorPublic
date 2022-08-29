//
//  File.swift
//  KetoCalculator
//
//  Created by toaster on 2021/11/23.
//

import Foundation
import UIKit

extension UIViewController {
    func presentAlert(title: String, message: String, actionTitle: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let alertAction = UIAlertAction(title: actionTitle,
                                        style: .default,
                                        handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}
