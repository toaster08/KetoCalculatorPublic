//
//  TabBarViewController.swift
//  KetoCalculator
//
//  Created by toaster on 2021/12/14.
//

import UIKit

final class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        tabBar.unselectedItemTintColor = #colorLiteral(red: 1, green: 0.36759758, blue: 0.4156255126, alpha: 1)
        selectedIndex = 1
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is CalculatorViewController {
            tabBarController.tabBar.backgroundColor = UIColor(named: "MainTabBarTintColor")
            tabBarController.tabBar.barTintColor = UIColor(named: "MainTabBarTintColor")
            tabBarController.tabBarItem.badgeColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            tabBar.unselectedItemTintColor = #colorLiteral(red: 1, green: 0.36759758, blue: 0.4156255126, alpha: 1)
        }

        if viewController is SettingNavigationViewController {
            tabBarController.tabBar.backgroundColor = UIColor(named: "SettingTabBarTintColor")
            tabBarController.tabBar.barTintColor = UIColor(named: "SettingTabBarTintColor")
            tabBarController.tabBarItem.badgeColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            tabBar.unselectedItemTintColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        }

        if viewController is FoodTableNavigationController {
            tabBarController.tabBar.backgroundColor = UIColor(named: "FoodTableTabBarTintColor")
            tabBarController.tabBar.barTintColor = UIColor(named: "FoodTableTabBarTintColor")
            tabBarController.tabBarItem.badgeColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            tabBar.unselectedItemTintColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        }
    }
}
