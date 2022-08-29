//
//  AppDescriptionViewController.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/03/24.
//

import UIKit

final class AppDescriptionViewController: UIViewController {
    @IBOutlet private weak var appDescriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        appDescriptionTextView.textContainerInset = UIEdgeInsets(top: 5, left: 15, bottom: 10, right: 15)
        // Do any additional setup after loading the view.
    }
}
