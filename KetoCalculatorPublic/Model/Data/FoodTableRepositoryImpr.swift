//
//  RealmRepository.swift
//  FoodCompositRealmSample
//
//  Created by 山田　天星 on 2022/03/09.
//

import Foundation
import RealmSwift

protocol FoodTableRepository {
    func loadFoodTable() async -> [FoodObject]
}

final class FoodTabelRepositoryImpr: FoodTableRepository {
    private var realm: Realm

    init() {
        do {
//            let config = Realm.Configuration(
//                fileURL: Bundle.main.url(forResource: "seed", withExtension: "realm"),
////                readOnly: true,
//                schemaVersion: 1,
//                migrationBlock: { _, _ in})

//            let config = Realm.Configuration(
//                schemaVersion: 1,
//                migrationBlock: { _, _ in})

//            self.realm = try Realm(configuration: config)
            self.realm = try Realm()
            print(Realm.Configuration.defaultConfiguration.fileURL)
        } catch {
            fatalError()
        }
    }

    func initializeRealm() {
        deleteRealm()
        guard let defaultConfigurationFileURL =  Realm.Configuration.defaultConfiguration.fileURL,
              let seedDataFileURL =  Bundle.main.url(forResource: "seed", withExtension: "realm") else {
                  return print("FileURLが見つかりません")
              }

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: defaultConfigurationFileURL.path) {
            // swiftlint:disable force_try
            try! fileManager.copyItem(at: seedDataFileURL,
                                      to: defaultConfigurationFileURL)
            // swiftlint:enable force_try
            print("realmを生成しました")
        }
    }

    func deleteRealm() {
        do {
            guard let defaultURL = Realm.Configuration.defaultConfiguration.fileURL else {
                print("Realm.Configuration.defaultConfiguration.fileURL is missing")
                return
            }
            try FileManager.default.removeItem(at: defaultURL)
            print("completed to delete default.realm")
        } catch {
            print("failed to delete default.realm")
        }
    }

    func loadFoodTable() async -> [FoodObject] {
        let allFoodsResults
        = realm
            .objects(FoodComposition.self)
            .sorted(byKeyPath: "id",
                    ascending: true)

        let allFoods = Array(allFoodsResults).map {
            FoodObject(food: $0)
        }

        return allFoods
    }
}
