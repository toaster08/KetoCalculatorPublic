//
//  RealmModel.swift
//  FoodCompositRealmSample
//
//  Created by 山田　天星 on 2022/02/23.
//

import Foundation
import RealmSwift

// Entity
class FoodComposition: Object {
    // swiftlint:disable identifier_name
    @Persisted var id: Int?
    @Persisted var food_code: Int?
    @Persisted var food_name: String?
    // swiftlint:enable identifier_name
    @Persisted var energy: Int?
    @Persisted var water: Double?
    @Persisted var protein: Double?
    @Persisted var fat: Double?
    @Persisted var dietaryfiber: Double?
    @Persisted var carbohydrate: Double?
    @Persisted var category: String?
    @Persisted var favorite: Bool
}
