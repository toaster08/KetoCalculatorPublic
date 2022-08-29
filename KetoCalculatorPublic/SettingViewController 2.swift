//
//  SettingViewController.swift
//  KetoCalculator
//
//  Created by toaster on 2021/11/20.
//

import UIKit
import SafariServices

protocol buttonRectangleProtocol {
    func setButtonRectangle(at rect: CGRect)
}

final class SettingViewController: UIViewController {
    // UserDefaults
    static let ketogenicRatioTargetValueKey = "ketogenicRatioTargetValueKey"
    static let ketogenicIndexTargetValueKey = "ketogenicIndexTargetValueKey"
    static let ketogenicValueTargetValueKey = "ketogenicValueTargetValueKey"
    static let totalEnergyExpenditureKey = "totalEnergyExpenditureKey"
    // UserDefalutsからの値の格納先
    private let settingUserDefaults = SettingUserDefaults()
    private var ratioTargetValue: Double?
    private var indexTargetValue: Double?
    private var numberTargetValue: Double?
    private var selectedEquation: Int?
    private var totalEnergyExpenditure: Double?
    // Viewの配置設定関係
    private var settingButtonPosition: CGPoint?
    private var uiView: [UIView] {
        [segmentedControlView,
         ketogenicNumberTargetView,
         postFeedView,
         settingTEEView,
         privacypolicyView]
    }
    // 指標の初期位置の設定関連
    @IBOutlet private weak var segmentedControlView: UIView!
    @IBOutlet private weak var defaultSegementedControl: UISegmentedControl!
    // ケトン指標の値の設定関連
    @IBOutlet private weak var ketogenicNumberTargetView: UIView!
    @IBOutlet private weak var ketogenicRatioTargetStepper: UIStepper!
    @IBOutlet private weak var ketogenicIndexTargetStepper: UIStepper!
    @IBOutlet private weak var ketogenicValueTargetStepper: UIStepper!
    @IBOutlet private weak var ketogenicRatioTargetTextField: UITextField!
    @IBOutlet private weak var ketogenicIndexTargetTextField: UITextField!
    @IBOutlet private weak var ketogenicValueTargetTextField: UITextField!
    // 必要エネルギー量の設定関連
    @IBOutlet private weak var settingTEEView: UIView!
    @IBOutlet private weak var settingTEETextField: UITextField!
    // WordPressのAPI通信関連
    @IBOutlet private weak var postFeedView: UIView!

    // 改修箇所
    @IBOutlet private weak var privacypolicyButton: UIButton!
    @IBOutlet private weak var privacypolicyView: UIView!

    // 各種設定保存のButton関連
    @IBOutlet private weak var settingSaveButton: UIButton!

    @IBOutlet weak private var buttonBackGradationView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Viewのセットアップ
        setup()
        // UserDefaultsのセット
        loadUserDefaults()

        // メソッド
        defaultSegementedControl
            .addTarget(self,
                       action: #selector(segmentedControleValueChanged),
                       for: .valueChanged)

        [ketogenicRatioTargetStepper,
         ketogenicIndexTargetStepper,
         ketogenicValueTargetStepper]
            .forEach {
                $0.addTarget(self,
                             action: #selector(stepTargetTouchUpInside),
                             for: .touchUpInside)
            }

        settingTEETextField
            .addTarget(self,
                       action: #selector(settingREEEditingChanged),
                       for: .editingChanged)

        privacypolicyButton
            .addTarget(self,
                       action: #selector(privacypolicyTouchUpInside),
                       for: .touchUpInside)

        settingSaveButton
            .addTarget(self,
                       action: #selector(saveSetting),
                       for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        loadUserDefaults()
    }

    private func loadUserDefaults() {
        selectedEquation = settingUserDefaults.loadDefaultIndexType()
        ratioTargetValue = settingUserDefaults
            .loadDefaultTargetValue(targetValueKey: Self.ketogenicRatioTargetValueKey)
        indexTargetValue = settingUserDefaults
            .loadDefaultTargetValue(targetValueKey: Self.ketogenicIndexTargetValueKey)
        numberTargetValue = settingUserDefaults
            .loadDefaultTargetValue(targetValueKey: Self.ketogenicValueTargetValueKey)
        totalEnergyExpenditure = settingUserDefaults.loadDefaultTEE()

        if let ratioTargetValue = ratioTargetValue {
            ketogenicRatioTargetTextField.text = String(format: "%.1f", ratioTargetValue)
            ketogenicRatioTargetStepper.value = ratioTargetValue
        }

        if let indexTargetValue = indexTargetValue {
            ketogenicIndexTargetTextField.text = String(format: "%.1f", indexTargetValue)
            ketogenicIndexTargetStepper.value = indexTargetValue
        }

        if let numberTargetValue = numberTargetValue {
            ketogenicValueTargetTextField.text = String(format: "%.1f", numberTargetValue)
            ketogenicValueTargetStepper.value = numberTargetValue
        }

        if let selectedEquation = selectedEquation {
            defaultSegementedControl.selectedSegmentIndex = selectedEquation
        }

        if let requiredEnergyExpenditure = totalEnergyExpenditure {
            settingTEETextField.text = String(format: "%.f", requiredEnergyExpenditure)
        }
    }

    private func setup() {
        uiView.forEach {
            $0.layer.cornerRadius = 10
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.3
        }

        settingSaveButton.map {
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowColor = UIColor.white.cgColor
            $0.layer.shadowOpacity = 0.7
            $0.layer.borderColor = UIColor.clear.cgColor
            $0.layer.borderWidth = 5
            $0.layer.cornerRadius = $0.frame.width / 2

            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = $0.bounds
            let color1 = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1).cgColor
            let color2 = #colorLiteral(red: 0.5174773335, green: 0.8167103529, blue: 1, alpha: 1).cgColor
            let color3 = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1).cgColor
            gradientLayer.colors = [color1, color2, color3]
            gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
            gradientLayer.cornerRadius = $0.frame.width / 2
            $0.layer.insertSublayer(gradientLayer, at: 0)
        }

        buttonBackGradationView.map {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = $0.bounds
            let color1 = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0).cgColor
            let color2 = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1).cgColor
            gradientLayer.colors = [color1, color2]
            gradientLayer.startPoint = CGPoint.init(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
            $0.layer.insertSublayer(gradientLayer, at: 0)
        }
    }

    @objc private func privacypolicyTouchUpInside() {
        let privacypolicyURL = "https://ytoaster.com/ketocalclator/"
        let url = URL(string: privacypolicyURL)
        if let url = url {
            let privacypolicyVC = SFSafariViewController(url: url)
            present(privacypolicyVC, animated: true, completion: nil)
        }
    }

    @objc private func segmentedControleValueChanged() {
        selectedEquation = defaultSegementedControl.selectedSegmentIndex
    }

    @objc private func stepTargetTouchUpInside() {
        ratioTargetValue = ketogenicRatioTargetStepper.value
        indexTargetValue = ketogenicIndexTargetStepper.value
        numberTargetValue = ketogenicValueTargetStepper.value

        guard let ratioTargetValue = ratioTargetValue,
              let indexTargetValue = indexTargetValue,
              let numberTargetValue = numberTargetValue else {
            return
        }

        ketogenicRatioTargetTextField.text = String(format: "%.1f", ratioTargetValue)
        ketogenicIndexTargetTextField.text = String(format: "%.1f", indexTargetValue)
        ketogenicValueTargetTextField.text = String(format: "%.1f", numberTargetValue)
    }

    @objc private func settingREEEditingChanged() {
        let TEE = settingTEETextField.flatMap { Double($0.text ?? "") }
        // バリデーション構築するまではこれで対応
        totalEnergyExpenditure = TEE
    }

    @objc private func saveSetting() {
        animateView(settingSaveButton)

        guard let ratioTargetValue = ratioTargetValue,
              let indexTargetValue = indexTargetValue,
              let numberTargetValue = numberTargetValue,
              let selectedEquation = selectedEquation,
              let totalEnergyExpenditure = totalEnergyExpenditure else {
            return
        }

        settingUserDefaults
            .save(targetValue: ratioTargetValue,
                  targetValueKey: Self.ketogenicRatioTargetValueKey)
        settingUserDefaults
            .save(targetValue: indexTargetValue,
                  targetValueKey: Self.ketogenicIndexTargetValueKey)
        settingUserDefaults
            .save(targetValue: numberTargetValue,
                  targetValueKey: Self.ketogenicValueTargetValueKey)
        settingUserDefaults
            .save(selectedEquation: selectedEquation)
        settingUserDefaults
            .save(TEE: totalEnergyExpenditure)
        settingUserDefaults.hasSaved(flug: true)
    }
}

extension SettingViewController: buttonRectangleProtocol {
    func setButtonRectangle(at rect: CGRect) {
        self.settingSaveButton.frame = rect
    }
}
