//
//  PaywallVIewController.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/08/09.
//

import Foundation
import UIKit
import RevenueCat

enum AccountStatus {
    case pro
    case normal
}

class PaywallViewController: UIViewController {
    var package: Package?
    var offering: Offering?

    @IBOutlet private weak var subscribeButton: UIButton!
    @IBOutlet private weak var trialTextLabel: UILabel!
    @IBOutlet private weak var restoreButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        subscribeButton
            .addTarget(
                self,
                action: #selector(subscribeButtonDidTapped),
                for: .touchUpInside
            )

        restoreButton
            .addTarget(
                self,
                action: #selector(restoreButtonDidTapped),
                for: .touchUpInside
            )

        refreshView()
    }

    func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }

    func fetchPurchaseOffrings() async {
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                print(error.localizedDescription)
            }
            self.offering = offerings?.current
        }
    }

    func refreshView() {
        package = self.offering?.availablePackages.first
        guard let package = package else {
            return
        }

        Purchases.shared.getCustomerInfo { customerInfo, _ in
            if customerInfo?.entitlements[Constants.entitlementID]?.isActive == true {
                let title = "購入済み"
                self.subscribeButton.setTitle(title, for: .normal)
                self.subscribeButton.backgroundColor = .lightGray
                self.subscribeButton.isUserInteractionEnabled = false
            } else {
                let title =  package.storeProduct.localizedTitle
                let price = package.localizedPriceString
                let buttonText = "\(title) : \(price)"
                self.subscribeButton.setTitle(buttonText, for: .normal)
            }
        }

        if let intro = package.storeProduct.introductoryDiscount {
            let packageTermsLabelText = intro.price == 0
            ? "\(intro.subscriptionPeriod.periodTitle()) free trial"
            : "\(package.localizedIntroductoryPriceString!) for \(intro.subscriptionPeriod.periodTitle())"
            trialTextLabel.text = packageTermsLabelText
        }
    }

    @objc func subscribeButtonDidTapped() {
        guard let package = package else {
            return
        }

        Purchases.shared.purchase(package: package) { _, purchaserInfo, error, _ in
            if let error = error {
                self.present(
                    UIAlertController
                        .errorAlert(message: error.localizedDescription), animated: true, completion: nil)
            } else {
                if purchaserInfo?.entitlements[Constants.entitlementID]?.isActive == true {
                    DispatchQueue.main.async {
                        if let calculatorVC = self.presentingViewController?.children[1] as? CalculatorViewController {
                            calculatorVC.verifyAccount()
                            calculatorVC.fetchArticle()
                        }
                    }

                    self.dismissModal()
                }
            }
        }
    }

    @objc func restoreButtonDidTapped() {
        subscribeButton.isUserInteractionEnabled = false

        Purchases.shared.restorePurchases { _, error in
            if let error = error {
                self.present(UIAlertController.errorAlert(message: error.localizedDescription), animated: true, completion: nil)
            }
            Task {
                await self.fetchPurchaseOffrings()
                self.refreshView()
                self.subscribeButton.isUserInteractionEnabled = true
            }
        }
    }
}

/* Some methods to make displaying subscription terms easier */
extension SubscriptionPeriod {
    var durationTitle: String {
        switch self.unit {
        case .day: return "日"
        case .week: return "週"
        case .month: return "月"
        case .year: return "年"
        default: return "不明"
        }
    }

    func periodTitle() -> String {
        let periodString = "\(self.value) \(self.durationTitle)"
        let pluralized = self.value > 1 ?  periodString + "間" : periodString
        return pluralized
    }
}
