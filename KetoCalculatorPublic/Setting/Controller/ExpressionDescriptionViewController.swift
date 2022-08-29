//
//  ExpressionDescriptionViewController.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/03/24.
//

import UIKit

final class ExpressionDescriptionViewController: UIViewController {
    @IBOutlet private weak var expressionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        expressionTextView
            .textContainerInset = UIEdgeInsets(top: 30,
                                               left: 15,
                                               bottom: 10,
                                               right: 15)
    }
}
