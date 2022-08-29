//
//  SettingViewController.swift
//  KetoCalculator
//
//  Created by toaster on 2021/11/20.
//

import UIKit

final class SettingViewController: UIViewController {
    // UserDefalutsからの値の格納先
    private let userSetRepository = UserSetRepository()
    private var ratioTargetValue: Double?
    private var indexTargetValue: Double?
    private var valueTargetValue: Double?
    private var selectedSegementIndex: Int?
    private var selectedIndexType: KetogenicIndexType?
    private var totalEnergyExpenditure: Double?
    // Viewの配置設定関係
    var settingButtonPosition: CGRect?
    private let gradientLayer = CAGradientLayer()

    private var uiView: [UIView] {
        [segmentedControlView,
         ketogenicNumberTargetView,
         postFeedView,
         settingTEEView,
         privacypolicyView]
    }

    // Headerとして利用するView
    @IBOutlet private weak var headerTitleLabel: UILabel!
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

        settingSaveButton
            .addTarget(self,
                       action: #selector(saveSetting),
                       for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        settingSaveButton.layer.cornerRadius = settingSaveButton.frame.width / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        loadUserDefaults()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
                guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
                    return
                }

                if traitCollection.userInterfaceStyle == .dark {
                    print("traitCollection:dark mode")
                    setupGradientLayer()
                } else if traitCollection.userInterfaceStyle == .light {
                    print("traitCollection:light mode")
                    setupGradientLayer()
                }
        }
    }

    private func loadUserDefaults() {
//        selectedEquation = userSetRepository.loadDefaultIndexType()
        segmentedControleValueChanged()
        selectedIndexType = userSetRepository.loadInitialIndexType()
        ratioTargetValue = userSetRepository.loadTargetValue(indexType: .ketogenicRatio)
        indexTargetValue = userSetRepository.loadTargetValue(indexType: .ketogenicIndex)
        valueTargetValue = userSetRepository.loadTargetValue(indexType: .ketogenicValue)
        totalEnergyExpenditure = userSetRepository.loadDefaultTEE()

        if let ratioTargetValue = ratioTargetValue {
            ketogenicRatioTargetTextField.text = String(format: "%.1f", ratioTargetValue)
            ketogenicRatioTargetStepper.value = ratioTargetValue
        }

        if let indexTargetValue = indexTargetValue {
            ketogenicIndexTargetTextField.text = String(format: "%.1f", indexTargetValue)
            ketogenicIndexTargetStepper.value = indexTargetValue
        }

        if let numberTargetValue = valueTargetValue {
            ketogenicValueTargetTextField.text = String(format: "%.1f", numberTargetValue)
            ketogenicValueTargetStepper.value = numberTargetValue
        }

        if let selectedIndexType = selectedIndexType {
            defaultSegementedControl.selectedSegmentIndex = selectedIndexType.rawValue
        }

        if let totalEnergyExpenditure = totalEnergyExpenditure {
            settingTEETextField.text = String(format: "%.f", totalEnergyExpenditure)
        }
    }

    private func setup() {
        postFeedView.isHidden = true

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
        }

        setupGradientLayer()
    }

    private func setupGradientLayer() {
        buttonBackGradationView.map {
            gradientLayer.frame = $0.bounds
            let color1 = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0).cgColor
            let color2 = UIColor(named: "SettingClearColor")?.cgColor
            gradientLayer.colors = [color1, color2!]
            gradientLayer.startPoint = CGPoint.init(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
            $0.layer.insertSublayer(gradientLayer, at: 0)
        }
    }

    @objc private func segmentedControleValueChanged() {
        selectedSegementIndex = defaultSegementedControl.selectedSegmentIndex
    }

    @objc private func stepTargetTouchUpInside() {
        ratioTargetValue = ketogenicRatioTargetStepper.value
        indexTargetValue = ketogenicIndexTargetStepper.value
        valueTargetValue = ketogenicValueTargetStepper.value

        guard let ratioTargetValue = ratioTargetValue,
              let indexTargetValue = indexTargetValue,
              let numberTargetValue = valueTargetValue else {
            return
        }

        ketogenicRatioTargetTextField.text = String(format: "%.1f", ratioTargetValue)
        ketogenicIndexTargetTextField.text = String(format: "%.1f", indexTargetValue)
        ketogenicValueTargetTextField.text = String(format: "%.1f", numberTargetValue)
    }

    @objc private func settingREEEditingChanged() {
        let TEE = settingTEETextField.flatMap { Double($0.text ?? "") }
        totalEnergyExpenditure = TEE
    }

    @objc private func saveSetting() {
        guard let ratioTargetValue = ratioTargetValue,
              let indexTargetValue = indexTargetValue,
              let valueTargetValue = valueTargetValue else {
                  return
              }

        guard let selectedSegmentIndex = selectedSegementIndex else {
            print("selectedSegmentIndex is nil")
            return
        }
        guard let totalEnergyExpenditure = totalEnergyExpenditure else {
            print("totalEnergyExpenditure is nil")
            return
        }

        for ketogenicIndexType in KetogenicIndexType.allCases {
            userSetRepository.save(indexType: ketogenicIndexType) {
                switch ketogenicIndexType {
                case .ketogenicRatio: return ratioTargetValue
                case .ketogenicIndex: return indexTargetValue
                case .ketogenicValue: return valueTargetValue
                }
            }
        }

        userSetRepository
            .save(initialIndexTypeSegment: selectedSegmentIndex)
        userSetRepository
            .save(totalEnergyExpenditure: totalEnergyExpenditure)
        userSetRepository.hasSaved(flug: true)

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

//        userSetRepository
//            .save(targetKetogenicRatio: ratioTargetValue)
//        userSetRepository
//            .save(targetKetogenicIndex: indexTargetValue)
//        userSetRepository
//            .save(targetKetogenicValue: valueTargetValue)
