//
//  CalculatorViewController+Activity.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/26.
//

import Foundation
import UIKit

// TODO: 単位を揃える
extension CalculatorViewController {
    @objc func sharePost() {
        guard let ketogenicCalculatedResult = ketogenicCalculatedResult else { return }

        let comopositionText: String
        switch selectedIndexType {
        case .ketogenicRatio:
            guard let pfc = pfc else { return }
            comopositionText = """
            ケトン比：\(ketogenicCalculatedResult)
            エネルギー：\(pfc.energy)kcal
            たんぱく質：\(pfc.protein)g
            脂質：\(pfc.fat)g
            炭水化物：\(pfc.carbohydrate)g
            """
        case .ketogenicIndex:
            guard let pfc = pfc else { return }
            comopositionText = """
            ケトン指数：\(ketogenicCalculatedResult)
            エネルギー：\(pfc.energy)kcal
            たんぱく質：\(pfc.protein)g
            脂質：\(pfc.fat)g
            炭水化物：\(pfc.carbohydrate)g
            """
        case .ketogenicValue:
            guard let pfs = pfs else { return }
            comopositionText = """
            ケトン値：\(ketogenicCalculatedResult)
            エネルギー：\(pfs.energy)kcal
            たんぱく質：\(pfs.protein)g
            脂質：\(pfs.fat)g
            糖質：\(pfs.sugar)g
            """
        }

        let hashTag = "#ケトン食"
        let shareURL = URL(string: "https://apps.apple.com/us/app/ketocalculator/id1607633652")!
        let shareItems = [comopositionText, hashTag, shareURL] as [Any]
        let controller = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)

        controller.excludedActivityTypes = [
           .addToReadingList,
           .airDrop,
           .assignToContact,
           .openInIBooks,
           UIActivity.ActivityType(rawValue: "com.apple.reminders.sharingextension")
        ]

        let viewController = UIApplication.shared.windows.first?.rootViewController
        viewController?.present(controller, animated: true, completion: nil)
    }

    @objc func transitExpressionInformation() {
        let vcString = "ExpressionDescriptionViewController"
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        guard let descriptionVC
                = storyboard
                .instantiateViewController(
                    withIdentifier: vcString
                ) as? ExpressionDescriptionViewController else {
                    return
                }

        present(descriptionVC, animated: true, completion: nil)
    }
}
