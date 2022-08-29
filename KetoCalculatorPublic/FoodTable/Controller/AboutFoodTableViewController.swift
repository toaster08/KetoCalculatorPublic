//
//  AboutFoodTableViewController.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/30.
//

import UIKit
import SafariServices

class AboutFoodTableViewController: UIViewController {
    @IBOutlet private weak var formerTextView: UITextView!
    @IBOutlet private weak var latterTextView: UITextView!

    @IBOutlet private weak var mextBannerImageView: UIImageView!
    @IBOutlet private weak var foodTableButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        foodTableButton
            .addTarget(
                self,
                action: #selector(didTappedFoodTableButton),
                for: .touchUpInside
            )

        [formerTextView, latterTextView].forEach {
            $0?.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        }
    }

    @objc func didTappedFoodTableButton() {
        let url = URL(string: "https://www.mext.go.jp/a_menu/syokuhinseibun/index.htm")!
        let privacypolicyVC = SFSafariViewController(url: url)
        present(privacypolicyVC, animated: true, completion: nil)
    }
}
