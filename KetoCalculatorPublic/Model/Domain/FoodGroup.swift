//
//  CategoryType.swift
//  FoodCompositionTables
//
//  Created by 山田　天星 on 2022/05/01.
//

import Foundation

enum FoodGroup: Int, CaseIterable {
    case cereals = 0
    case potatoes // potatoes And Starches
    case sugars // sugars
    case pulses
    case nutsAndSeeds
    case vegitables
    case fruits
    case mushrooms
    case algae
    case fish // fish mollusks and crustaceans
    case meat
    case eggs
    case milk // milk and milk products
    case fats // fats and oils
    case confectionaries
    case beverages
    case seasonings // Seasonings and spices
    case preparedfoods

    var name: String {
        switch self {
        case .cereals: return "１ 穀類"
        case .potatoes: return "２ いも及びでん粉類"
        case .sugars: return "３ 砂糖及び甘味類"
        case .pulses: return "４ 豆類"
        case .nutsAndSeeds: return "5 種実類"
        case .vegitables: return "6 野菜類"
        case .fruits: return "7 果実類"
        case .mushrooms: return "8 きのこ類"
        case .algae: return "9 藻類"
        case .fish: return "10 魚介類"
        case .meat: return "11 肉類"
        case .eggs: return "12 卵類"
        case .milk: return "13 乳類"
        case .fats: return "14 油脂類"
        case .confectionaries: return "15 菓子類"
        case .beverages: return "16 し好飲料類"
        case .seasonings: return "17 調味料及び香辛料類"
        case .preparedfoods: return "18　調理済み流通食品類"
        }
    }

    init?(value: String?) {
        guard let value = value else { return nil }

        // これはOKで
        let initializeCategory = FoodGroup.allCases.first(where: { group in
            group.name == value
        })

        self = initializeCategory!
    }
}
