//
//  FoodTableViewController.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/07/19.
//

import Foundation
import UIKit
import GoogleMobileAds
import RealmSwift

final class FoodTableViewController: UIViewController {
    private var selectFoodTableVC: SelectFoodTableViewCotroller?

    private var selectFood: FoodObject?

    private var defaultFoodTable: FoodTable = FoodTable()
    private var searchedFoodTable: FoodTable = FoodTable()
    private var favoriteFoodTable: FoodTable = FoodTable()

    private var currentFoodTable: FoodTable {
        if !(searchController?.searchBar.text?.isEmpty)! {
            return searchedFoodTable
        }

        if foodListSegemetedControl.selectedSegmentIndex == 0 {
            return defaultFoodTable
        } else if foodListSegemetedControl.selectedSegmentIndex == 1 {
            print(favoriteFoodTable)
            return favoriteFoodTable
        }

        fatalError()
    }

    @IBOutlet private weak var tableView: UITableView!

    // SearchController
    private var searchController: UISearchController?
    @IBOutlet private weak var makeRecipeBarButton: UIBarButtonItem!
    @IBOutlet private weak var aboutTableInfomation: UIBarButtonItem!

    // SegmentedControl
    private var ketogenecTypeSegment: KetogenicIndexType? {
        let index = ketogenicTypeSegmentedControl.selectedSegmentIndex
        return KetogenicIndexType(rawValue: index) ?? nil
    }
    @IBOutlet private weak var ketogenicTypeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var foodListSegemetedControl: UISegmentedControl!

    // GADBanner
    private var bannerView: GADBannerView!
    @IBOutlet private weak var bannerParentView: UIView!

    // LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        tableView
            .register(
                UINib(nibName: "CustomTableViewCell", bundle: nil),
                forCellReuseIdentifier: "CustomTableViewCell"
            )
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag

        selectFoodTableVC = makeSelectFoodTable()

        Task {
            defaultFoodTable = await FoodTable()
            favoriteFoodTable = defaultFoodTable.getFavoriteList()
            tableView.reloadData()
        }

        ketogenicTypeSegmentedControl
            .addTarget(
                self,
                action: #selector(ketogenicTypeDidTapped),
                for: .valueChanged
            )

        foodListSegemetedControl
            .addTarget(
                self,
                action: #selector(foodListSegementedControlDidTapped),
                for: .valueChanged
            )

        makeRecipeBarButton.target = self
        makeRecipeBarButton.action = #selector(recipeBarButtonDidTapped)

        configureGADBanner()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailVC = segue.destination as? FoodDetailViewController else { return }
        guard let selectFood = selectFood else { return }
        detailVC.selectFood = selectFood
        detailVC.hidesBottomBarWhenPushed = true
        detailVC.recipeInputDelegate = selectFoodTableVC
    }

    private func setup() {
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController

        searchController?.searchBar.delegate = self
        searchController?.searchBar.searchTextField.delegate = self
    }

    private func makeSelectFoodTable() -> SelectFoodTableViewCotroller? {
        let tableIdentifier = "SelectFoodTableViewCotroller"
        guard let selectFoodTableVC =
                storyboard?
                .instantiateViewController(
                    withIdentifier: tableIdentifier
                ) as? SelectFoodTableViewCotroller else { return nil }
        return selectFoodTableVC
    }

    // 実質的に検索を担うメソッド
    private func search(for sectionFoods: [FoodObject], in text: String) -> [FoodObject] {
        let searchedSectionFoods
        = sectionFoods
            .filter {
                let searchedFood = $0.name.contains(text.lowercased())
                return searchedFood
            }

        return searchedSectionFoods
    }

    // 二次元配列のFoodTableからの検索の呼び出しメソッド
    private func search(for foodTable: FoodTable, in searchText: String) -> FoodTable {
        let searchedFoodListForTable
        = foodTable.list.compactMap { sectionFoods -> [FoodObject]? in
            let searchedSectionFoods = search(for: sectionFoods, in: searchText)
            if !searchedSectionFoods.isEmpty {
                return searchedSectionFoods
            }
            return nil
        }

        return FoodTable(foodTable: searchedFoodListForTable)
    }
}

extension FoodTableViewController {
    @objc func ketogenicTypeDidTapped() {
        tableView.reloadData()
    }

    @objc func foodListSegementedControlDidTapped() {
        print(#function)

        if foodListSegemetedControl.selectedSegmentIndex == 1 {
            favoriteFoodTable = defaultFoodTable.getFavoriteList()
        }

        tableView.reloadData()
    }

    @objc func recipeBarButtonDidTapped() {
        guard let selectFoodTableVC = selectFoodTableVC else { return }
        if let sheet = selectFoodTableVC.sheetPresentationController {
            sheet.detents = [
                .medium(),
                .large()
            ]
        }
        selectFoodTableVC.currentKetogenicType = ketogenecTypeSegment
        present(selectFoodTableVC, animated: true)
    }

    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        guard let touch = event.allTouches?.first else { return }
        let point = touch.location(in: self.tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }

        var specifyFood = currentFoodTable.specifyFood(for: indexPath)
        specifyFood.favorite.toggle()

        var currentFoodTable = currentFoodTable
        currentFoodTable.update(for: specifyFood, at: indexPath)

        if (searchController?.searchBar.text?.isEmpty)! {
            if foodListSegemetedControl.selectedSegmentIndex == 0 {
                defaultFoodTable = currentFoodTable
            }

            if foodListSegemetedControl.selectedSegmentIndex == 1 {
                favoriteFoodTable = currentFoodTable

                let indexSection = defaultFoodTable.list.firstIndex { section in
                    section.first?.category == specifyFood.category
                }
                let indexRow = defaultFoodTable.list[indexSection!].firstIndex { food in
                    food.id == specifyFood.id
                }
                let defaultIndexPath = IndexPath(row: indexRow!, section: indexSection!)

                var fooTable = defaultFoodTable
                fooTable.update(for: specifyFood, at: defaultIndexPath)
                defaultFoodTable = fooTable
            }
        } else {
            searchedFoodTable = currentFoodTable
            let indexSection = defaultFoodTable.list.firstIndex { section in
                section.first?.category == specifyFood.category
            }
            let indexRow = defaultFoodTable.list[indexSection!].firstIndex { food in
                food.id == specifyFood.id
            }
            let defaultIndexPath = IndexPath(row: indexRow!, section: indexSection!)

            var fooTable = defaultFoodTable
            fooTable.update(for: specifyFood, at: defaultIndexPath)
            defaultFoodTable = fooTable
        }

        do {
            let realm = try Realm()
            try realm.write {
                var food
                = realm
                    .objects(FoodComposition.self)
                    .filter { foodComposition in
                        foodComposition.id == specifyFood.id
                    }.first
                food?.favorite.toggle()
            }
        } catch {
        }

        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension FoodTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectFood = currentFoodTable.specifyFood(for: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "toCompositionDetailVC", sender: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        print(currentFoodTable.groupNumber())
        return currentFoodTable.groupNumber()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // CategoryTypeによるsectionの区別
        let foodGroup = currentFoodTable.groupList()
        if !foodGroup.isEmpty {
            print(section)
            return foodGroup[section].name
        }

        return nil
    }
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentFoodTable.foodCount(in: section)
    }
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell
                = tableView
                .dequeueReusableCell(
                    withIdentifier: "CustomTableViewCell"
                ) as? CustomTableViewCell else {
                    fatalError()
                }

        guard let ketogenicType = ketogenecTypeSegment else {
            fatalError()
        }

        let food = currentFoodTable.specifyFood(for: indexPath)

        let figure: Double?
        if let value = food.calculateKetogenicValue(in: ketogenicType) {
            figure = value
        } else {
            figure = nil
        }

        cell.configure(for: food, figure: figure, in: ketogenicType)
        cell.favoriteButton
            .addTarget(
                self,
                action: #selector(handleButton(_:forEvent:)),
                for: .touchUpInside
            )
        return cell
    }
}

extension FoodTableViewController {
    func configureGADBanner() {
        bannerView = GADBannerView(adSize: GADAdSizeBanner)

#if DEBUG
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
#endif

        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        addBannerViewToView(bannerView)
    }

    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerParentView.backgroundColor = .clear
        bannerParentView.addSubview(bannerView)
        bannerView.topAnchor.constraint(equalTo: bannerParentView.topAnchor, constant: 0).isActive = true
        bannerView.bottomAnchor.constraint(equalTo: bannerParentView.bottomAnchor, constant: 0).isActive = true
        bannerView.leadingAnchor.constraint(equalTo: bannerParentView.leadingAnchor, constant: 0).isActive = true
        bannerView.trailingAnchor.constraint(equalTo: bannerParentView.trailingAnchor, constant: 0).isActive = true
    }
}

extension FoodTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print(#function)
        guard let searchText = searchController.searchBar.text else {
            return
        }

        if searchController.searchBar.searchTextField.isEditing {
            searchedFoodTable = search(for: defaultFoodTable, in: searchText)
            tableView.reloadData()
            tableView.isUserInteractionEnabled = true
        }
    }
}

extension FoodTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        tableView.reloadData()
    }
}

extension FoodTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(#function)
        tableView.isUserInteractionEnabled = false
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        print(#function)
        tableView.isUserInteractionEnabled = true
    }
}
