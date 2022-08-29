//
//  SettingUserDefaults.swift
//  KetoCalculator
//
//  Created by toaster on 2021/12/02.
//

import Foundation

protocol SettingRepository {
    func save(displayCount: Int)
    func save(initialIndexTypeSegment: Int)
    func save(totalEnergyExpenditure: Double)
    func hasSaved(flug: Bool)
    func save(indexType: KetogenicIndexType, targetValue: @escaping () -> Double)

    func loadRequestReviewCount() -> Int
//    func loadDefaultIndexType() -> Int
    func loadDefaultTEE() -> Double
    func loadSavedFlug() -> Bool
    func loadInitialIndexType() -> KetogenicIndexType
    func loadTargetValue(indexType: KetogenicIndexType) -> Double
}

final class UserSetRepository: SettingRepository {
    private let initialIndexTypeSegmentKey = "initialKetoEquationKey"
    private let ketogenicIndexTypeTargetValueKey = "ketogenicIndexTypeTargetValueKey"
    private let totalEnergyExpenditureKey = "totalEnergyExpenditureKey"

    private let ketogenicRatioTargetValueKey = "ketogenicRatioTargetValueKey"
    private let ketogenicIndexTargetValueKey = "ketogenicIndexTargetValueKey"
    private let ketogenicValueTargetValueKey = "ketogenicValueTargetValueKey"

    private let hasSavedFlugKey = "hasSavedFlugKey"
    private let useCountForReviewKey = "useCountForReview"

    let userDefaults = UserDefaults.standard

    func save(initialIndexTypeSegment: Int) {
        userDefaults.set(initialIndexTypeSegment, forKey: initialIndexTypeSegmentKey)
    }

    func save(indexType: KetogenicIndexType,
              targetValue: @escaping () -> Double) {
        let targetValue = targetValue()
        switch indexType {
        case .ketogenicRatio: userDefaults.set(targetValue, forKey: ketogenicRatioTargetValueKey)
        case .ketogenicIndex: userDefaults.set(targetValue, forKey: ketogenicIndexTargetValueKey)
        case .ketogenicValue: userDefaults.set(targetValue, forKey: ketogenicValueTargetValueKey)
        }
    }

    func save(totalEnergyExpenditure: Double) {
        userDefaults.setValue(totalEnergyExpenditure, forKey: totalEnergyExpenditureKey)
    }

    func hasSaved(flug: Bool) {
        userDefaults.set(flug, forKey: hasSavedFlugKey)
    }

    func save(displayCount: Int) {
        userDefaults.set(displayCount, forKey: useCountForReviewKey)
    }

    func loadRequestReviewCount() -> Int {
        return userDefaults.integer(forKey: useCountForReviewKey)
    }

//    func loadDefaultIndexType() -> Int {
//        let selectedIndexTypeRawValue = userDefaults.integer(forKey: initialKetoEquationKey)
//        return selectedIndexTypeRawValue
//    }

    func loadInitialIndexType() -> KetogenicIndexType {
        let selectedIndexTypeRawValue = userDefaults.integer(forKey: initialIndexTypeSegmentKey)

        if selectedIndexTypeRawValue <= KetogenicIndexType.allCases.count {
            return KetogenicIndexType(rawValue: selectedIndexTypeRawValue)!
        } else {
            fatalError("error: selectedIndexTypeRawValue > KetogenicIndexType.allCases.count")
        }
    }

    func loadTargetValue(indexType: KetogenicIndexType) -> Double {
        let targetValue: Double

        switch indexType {
        case .ketogenicRatio:
            targetValue = userDefaults.double(forKey: ketogenicRatioTargetValueKey)
        case .ketogenicIndex:
            targetValue = userDefaults.double(forKey: ketogenicIndexTargetValueKey)
        case .ketogenicValue:
            targetValue = userDefaults.double(forKey: ketogenicValueTargetValueKey)
        }

        return targetValue
    }

    func loadDefaultTEE() -> Double { // TEE: Total Energy Expenditure
        let defaultTEE = userDefaults.double(forKey: totalEnergyExpenditureKey)
        return defaultTEE
    }

    func loadSavedFlug() -> Bool {
        let defaultFlug = userDefaults.bool(forKey: hasSavedFlugKey)
        return defaultFlug
    }
}
