//
//  AppDelegate.swift
//  KetoCalculator
//
//  Created by toaster on 2021/10/30.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift
// import GoogleMobileAds
import RevenueCat

@main
class AppDelegate: UIResponder, UIApplicationDelegate, PurchasesDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        Purchases.logLevel = .debug
//        Purchases.configure(
//            with: Configuration.Builder(withAPIKey: Constants.apiKey)
//                .with(usesStoreKit2IfAvailable: true)
//                .build()
//        )
//        Purchases.shared.delegate = self

        IQKeyboardManager.shared.enable = true
        //        GADMobileAds.sharedInstance().start(completionHandler: nil)

        let config = Realm.Configuration(
                    schemaVersion: 3,
                    migrationBlock: { _, _ in})
        Realm.Configuration.defaultConfiguration = config

        let realm = FoodTabelRepositoryImpr()
        realm.initializeRealm()

//        do {
//            let config = Realm.Configuration(
//                fileURL: Bundle.main.url(forResource: "seed", withExtension: "realm"),
//                readOnly: true,
//                schemaVersion: 1,
//                migrationBlock: { _, _ in})
//
//            let realm = try Realm(configuration: config)
//        } catch {
//        }
//        let realm = FoodTabelRepositoryImpr()

        sleep(2)
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
