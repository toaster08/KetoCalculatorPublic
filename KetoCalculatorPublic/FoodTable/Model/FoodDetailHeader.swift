//
//  FoodDetailHeader.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/28.
//

import Foundation

enum Header: Int, CaseIterable {
    case userSetting
    case ketone
    case nutrients

    var name: String {
        switch self {
        case .userSetting: return "設定"
        case .ketone: return "ケトン"
        case .nutrients: return "詳細"
        }
    }

    var numberOfProperty: Int {
        switch self {
        case .userSetting: return 1
        case .ketone: return KetogenicIndexType.allCases.count
        case .nutrients: return FoodCompositionType.allCases.count
        }
    }

    static func identify(in indexPath: IndexPath) -> Header {
        guard let section = Header(rawValue: indexPath.section) else { fatalError() }
        return section
    }
}
