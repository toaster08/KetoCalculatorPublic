//
//  InfomationViewController.swift
//  KetoCalculator
//
//  Created by toaster on 2021/11/16.
//

import UIKit

protocol TargetAchivementOutput {
    func display(lipidRequirement: Double, currentEnergy: Double, TEE: Double)
    func judge(Of lipidRequirement: Double) -> String
    func setAttributes(number: Double, format: String, unit: String) -> NSMutableAttributedString
}

final class InformationViewController: UIViewController {
    var currentKetogenicIndexType: KetogenicIndexType?
    var pfc: PFC?
    var pfs: PFS?
    var percentEnergy: Double?

    let settingUserDefaults = UserSetRepository()
    private var hasSavedSetting = false
    private var loadedTargetValue: Double {
        loadDefaultTargetValue()
    }

    @IBOutlet private weak var exitButton: UIButton!
    @IBOutlet private weak var currentEnergyLabel: UILabel!
    // 目標値が考慮された値の算出先
    @IBOutlet private weak var targetStringLabel: UILabel!
    @IBOutlet private weak var targetAchivementView: UIView!
    @IBOutlet private weak var lipidRequirementView: UIView!
    @IBOutlet private weak var lipidRequirementLabel: UILabel!
    @IBOutlet private weak var targetEnergyLabel: UILabel!
    @IBOutlet private weak var targetPercentEnergyProgressView: UIProgressView!

    @IBOutlet private weak var targetPercentDescriptionLabel: UILabel!
    @IBOutlet private weak var targetPercentEnergyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettingHasSaved()

        if hasSavedSetting {
            guard let currentKetogenicIndexType
                    = currentKetogenicIndexType,
                  let lipidRequirement
                    = calculateLipidRequirement(in: currentKetogenicIndexType),
                  let energyAmount
                    = calculateEnergyAmount(in: currentKetogenicIndexType)
            else {
                return
            }

            let settingEnergyExpenditure = loadDefaultTEE()
            display(lipidRequirement: lipidRequirement,
                    currentEnergy: energyAmount,
                    TEE: settingEnergyExpenditure)
        } else {
            guard let currentKetogenicIndexType = currentKetogenicIndexType,
                  let currentEnergyAmount = calculateEnergyAmount(in: currentKetogenicIndexType) else {
                return
            }
            currentEnergyLabel.attributedText
                = setAttributes(number: currentEnergyAmount,
                                format: "%.f",
                                unit: " kcal")
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setup(setting: hasSavedSetting)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        progressPercentEnegey()
    }

    private func setup(setting hasSaved: Bool) {
        if hasSaved {
            targetPercentEnergyProgressView.transform
                = CGAffineTransform(scaleX: 1, y: 5)

            targetAchivementView.isHidden = false
            targetStringLabel.text = "目標値まで"

            [targetAchivementView,
             lipidRequirementView].forEach {
                $0?.layer.cornerRadius = 15
                $0?.layer.shadowOffset = CGSize(width: 0, height: 2)
                $0?.layer.shadowColor = UIColor.black.cgColor
                $0?.layer.shadowOpacity = 0.3
             }
        } else {
            let targetString = "設定をすると表示が追加されます"
            targetStringLabel.text = targetString
            targetAchivementView.isHidden = true
        }
    }

    private func progressPercentEnegey() {
        guard let percentEnergy = percentEnergy else { return }
        UIView.animate(withDuration: 1.5,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        self.targetPercentEnergyProgressView
                            .setProgress(Float(percentEnergy),
                                         animated: true)
                       },
                       completion: nil)
    }
}

// UserDefaultの読み込み
extension InformationViewController {
    private func loadSettingHasSaved() {
        hasSavedSetting = settingUserDefaults.loadSavedFlug()
    }

    private func loadDefaultTargetValue() -> Double {
        let targetValue: Double
        switch currentKetogenicIndexType {
        case .ketogenicRatio:
            targetValue = settingUserDefaults.loadTargetValue(indexType: currentKetogenicIndexType!)
        case .ketogenicIndex:
            targetValue = settingUserDefaults.loadTargetValue(indexType: currentKetogenicIndexType!)
        case .ketogenicValue:
            targetValue = settingUserDefaults.loadTargetValue(indexType: currentKetogenicIndexType!)
        case .none: fatalError()
        }
        return targetValue
    }

    private func loadDefaultTEE() -> Double {
        let settingEnergyExpenditure = settingUserDefaults.loadDefaultTEE()
        return settingEnergyExpenditure
    }
}

// 計算の処理
extension InformationViewController {
    private func calculateLipidRequirement(in ketogenicIndexType: KetogenicIndexType) -> Double? {
        let lipidRequirement: Double?
        switch ketogenicIndexType {
        case .ketogenicRatio:
            lipidRequirement
                = pfc?.lipidRequirementInKetogenicRatio(for: loadedTargetValue)
        case .ketogenicIndex:
            lipidRequirement
                = pfc?.lipidRequirementInKetogenicIndex(for: loadedTargetValue)
        case .ketogenicValue:
            lipidRequirement
                = pfs?.lipidRequirementInKetogenicValue(for: loadedTargetValue)
        }
        return lipidRequirement
    }

    private func calculateEnergyAmount(in ketogenicIndexType: KetogenicIndexType) -> Double? {
        let energyAmount: Double?
        switch ketogenicIndexType {
        case .ketogenicRatio:
            energyAmount = pfc?.energy
        case .ketogenicIndex:
            energyAmount = pfc?.energy
        case .ketogenicValue:
            energyAmount = pfs?.energy
        }
        return energyAmount
    }
}

extension InformationViewController: TargetAchivementOutput {
    func judge(Of lipidRequirement: Double) -> String {
        if  lipidRequirement <= -99.95 {
            return "-100g以上"
        } else if lipidRequirement <= -0.05 {
            return String(format: "%.1f", lipidRequirement) + "g"
        } else if lipidRequirement < 0.05 {
            return "過不足なし"
        } else if lipidRequirement < 99.95 {
            return"+\(String(format: "%.1f", lipidRequirement))" + "g"
        } else {
            return "+100g以上"
        }
    }

    func display(lipidRequirement: Double, currentEnergy: Double, TEE: Double) {
        let judgedLipidRequirement = judge(Of: lipidRequirement)

        lipidRequirementLabel.text = judgedLipidRequirement
        currentEnergyLabel.attributedText
            = setAttributes(number: currentEnergy, format: "%.f", unit: " kcal")

        let resultedEnergy = currentEnergy + (lipidRequirement * 9.0)
        targetEnergyLabel.attributedText
            = setAttributes(number: resultedEnergy, format: "%.f", unit: " kcal")

        let resultedPercentEnergy = resultedEnergy / TEE
        percentEnergy = resultedPercentEnergy

        if resultedPercentEnergy > 1.0 {
            targetPercentEnergyLabel.attributedText
                = setAttributes(number: 100, format: "%.f", unit: "％以上")
        } else {
            let percentEnergy = resultedPercentEnergy * 100
            targetPercentEnergyLabel.attributedText
                = setAttributes(number: percentEnergy, format: "%.f", unit: "％")
        }
    }

    func setAttributes(number: Double, format: String, unit: String) -> NSMutableAttributedString {
        let numberString =  String(format: format, number)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 45.0)
        ]
        let attributedNumberText = NSAttributedString(string: numberString, attributes: numberAttributes)
        let mutableAtrributedNumber = NSMutableAttributedString(attributedString: attributedNumberText)

        let unitArributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 30.0)
        ]
        let mutableAttributedUnitText = NSMutableAttributedString(string: unit, attributes: unitArributes)
        mutableAtrributedNumber.append(mutableAttributedUnitText)

        return mutableAtrributedNumber
    }
}
