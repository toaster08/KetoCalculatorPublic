//
//  ViewController.swift
//  KetoCalculator
//
//  Created by toaster on 2021/10/30.
//

import UIKit
import SafariServices
import StoreKit
// import RevenueCat

final class CalculatorViewController: UIViewController {
    private var accountStatus: AccountStatus = .normal
    private let settingUserDefaults = UserSetRepository()
    private var defaultTarget: Double?

    var pfc: PFC?
    var pfs: PFS?
    var ketogenicCalculatedResult: Double?
    private var calculatedResult: Double?

    // API通信用
    private var apiClient: APIClient?
    private var imageDownloader: ImageDownLoader?

    private var contents: [WordPressContent] = []
    private var articles: [WordPressArticles] = []
    private var imageData: [Data] = []

    private var collectionCellSize: CGSize {
        let height = articleFeedCollectionView.frame.height
        let width = articleFeedCollectionView.frame.width
        return CGSize(width: width, height: height)
    }

    private var hasSavedIndexType = false
    var selectedIndexType: KetogenicIndexType {
        switch ketogenicIndexTypeSegmentedControl.selectedSegmentIndex {
        case 0: return .ketogenicRatio
        case 1: return .ketogenicIndex
        case 2: return .ketogenicValue
        default: fatalError()
        }
    }

    private var inputTextFields: [UITextField] {
        [inputProteinTextField,
         inputFatTextField,
         inputCarbohydrateTextField,
         inputSugarTextField]
    }

    // ViewのIBパーツ
    @IBOutlet private weak var ketogenicTargetValueLabel: UILabel!
    @IBOutlet private weak var ketogenicIndexTypeSegmentedControl: UISegmentedControl!

    @IBOutlet private weak var calculatedResultBackgroundView: UIView!
    @IBOutlet private weak var calculatedResultLabel: UILabel!
    @IBOutlet private weak var resultLabelView: UIView!

    @IBOutlet private weak var articleFeedCollectionView: UICollectionView!
    @IBOutlet private weak var articleFeedReloadButton: UIButton!
    @IBOutlet private weak var articleFeedLoadingActivityIndicator: UIActivityIndicatorView!

    @IBOutlet private weak var inputProteinTextField: UITextField!
    @IBOutlet private weak var inputFatTextField: UITextField!
    @IBOutlet private weak var inputCarbohydrateTextField: UITextField!
    @IBOutlet private weak var inputSugarTextField: UITextField!

    @IBOutlet private weak var textFieldsStackView: UIStackView!
    @IBOutlet private weak var proteinStackView: UIStackView!
    @IBOutlet private weak var lipidStackView: UIStackView!
    @IBOutlet private weak var carbohydrateStackView: UIStackView!
    @IBOutlet private weak var inputTextFieldsBackgroundView: UIView!

    @IBOutlet private weak var accountStatusIndicator: UIImageView!
    @IBOutlet private weak var verifyAccountButton: UIButton!

    @IBOutlet private weak var calculateButton: UIButton!
    @IBOutlet private weak var shareResultButton: UIButton!
    @IBOutlet private weak var descriveExpressionButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // PROバージョンであるかの確認
//        verifyAccount()

        articleFeedReloadButton.isHidden = true
        // レイアウトのためのLabel表示
        calculatedResultLabel.text = nil
        //　CollectionViewの設定
        articleFeedCollectionView
            .register(UINib(nibName: "PostFeedCollectionViewCell", bundle: nil),
                      forCellWithReuseIdentifier: "PostFeedCollectionViewCell")
        articleFeedCollectionView.dataSource = self
        articleFeedCollectionView.delegate = self
        articleFeedCollectionView.isPagingEnabled = true

        // CollectionViewのFlowLayout設定
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        articleFeedCollectionView.collectionViewLayout = layout

        // UserDefalutより設定値の取得
        loadSavedFlug()
        loadDefaultTargetValue()
        loadDefaultEquation()

        // Viewのsetup
        setup()

        // WordPressを利用したAPI通信
        fetchArticle()

        // 各種メソッドの指定
        ketogenicIndexTypeSegmentedControl
            .addTarget(self,
                       action: #selector(segmentedControlValueChanged),
                       for: .valueChanged)

        inputTextFields.forEach {
            $0.addTarget(self,
                         action: #selector(textFieldEditingChanged),
                         for: .editingChanged)
        }

        calculateButton
            .addTarget(
                self,
                action: #selector(calculate),
                for: .touchUpInside
            )

        articleFeedReloadButton
            .addTarget(
                self,
                action: #selector(reloadButtonTouchUpInside),
                for: .touchUpInside
            )

        shareResultButton
            .addTarget(
                self,
                action: #selector(sharePost),
                for: .touchUpInside
            )

        descriveExpressionButton
            .addTarget(
                self,
                action: #selector(transitExpressionInformation),
                for: .touchUpInside
            )

        verifyAccountButton
            .addTarget(
                self,
                action: #selector(transitToSubscription),
                for: .touchUpInside
            )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let postCollectionFlowLayout
                = articleFeedCollectionView.collectionViewLayout
                as? UICollectionViewFlowLayout else {
                    return
                }

        postCollectionFlowLayout.itemSize
        = articleFeedCollectionView.frame.size

        if inputTextFieldsBackgroundView.frame.height < 220 {
            textFieldsStackView.setCustomSpacing(7, after: proteinStackView)
            textFieldsStackView.setCustomSpacing(7, after: lipidStackView)
            textFieldsStackView.setCustomSpacing(7, after: carbohydrateStackView)
        }

        setupGradient(frame: inputTextFieldsBackgroundView.bounds)
    }

    // MARK: 調べる
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
            guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
                return
            }

            if traitCollection.userInterfaceStyle == .dark {
                setupGradient(frame: inputTextFieldsBackgroundView.bounds)
            } else if traitCollection.userInterfaceStyle == .light {
                setupGradient(frame: inputTextFieldsBackgroundView.bounds)
            }
    }

    override func viewWillAppear(_ animated: Bool) {
        loadSavedFlug()
        loadDefaultTargetValue()
    }

    func verifyAccount() {
//        Purchases.shared.getCustomerInfo { customerInfo, _ in
//            if customerInfo?.entitlements[Constants.entitlementID]?.isActive == true {
//                UIView.animate(withDuration: 1) {
//                    self.accountStatusIndicator.image = UIImage(systemName: "circle.fill")
//                    self.accountStatusIndicator.tintColor = UIColor(named: "Gradient2")
//                    self.accountStatus = .pro
//                }
//            } else {
//                self.accountStatusIndicator.image = UIImage(systemName: "circle")
//                self.accountStatusIndicator.tintColor = .lightGray
//                self.accountStatus = .normal
//            }
//        }
    }

    private func setup() {
        inputTextFields.forEach {
            $0.layer.cornerRadius = 10
        }

        [inputTextFieldsBackgroundView,
         resultLabelView,
         articleFeedCollectionView].forEach {
            $0?.layer.setupRectangle()
        }

        calculateButton.map {
            $0.layoutIfNeeded()
            $0.isEnabled = false
            $0.layer.setupCircle(to: $0, opacity: 0.5)
            $0.titleLabel?.minimumScaleFactor = 0.1
        }

        enableTextField()
        enableInfomationButton()
        settingTextFieldDelegate()
        shareResultButton.isEnabled = false
    }

    private func setupGradient(frame: CGRect) {
        inputTextFieldsBackgroundView.map {
            let gradientLayer = CAGradientLayer.gradientLayer(in: $0.bounds)
            gradientLayer.cornerRadius = 10
            $0.layer.insertSublayer(gradientLayer, at: 0)
        }
    }

    private func loadSavedFlug() {
        hasSavedIndexType = settingUserDefaults.loadSavedFlug()
    }

    private func loadDefaultEquation() {
        guard hasSavedIndexType else {
            ketogenicIndexTypeSegmentedControl.selectedSegmentIndex = 0
            return
        }

        // ここの問題点はselectedSegmentIndexとrawValueの値が知識を前提として紐づいていること
        ketogenicIndexTypeSegmentedControl.selectedSegmentIndex
        = settingUserDefaults.loadInitialIndexType().rawValue
    }

    private func loadDefaultTargetValue() {
        guard hasSavedIndexType else {
            ketogenicTargetValueLabel.text = "目標値：未設定"
            return
        }

        switch selectedIndexType {
        case .ketogenicRatio:
            defaultTarget = settingUserDefaults.loadTargetValue(indexType: selectedIndexType)
        case .ketogenicIndex:
            defaultTarget = settingUserDefaults.loadTargetValue(indexType: selectedIndexType)
        case .ketogenicValue:
            defaultTarget = settingUserDefaults.loadTargetValue(indexType: selectedIndexType)
        }
        guard let defaultTarget = defaultTarget else { return }
        let targetValue = String(format: "%.1f", defaultTarget)
        ketogenicTargetValueLabel.text = "目標値：\(targetValue)"
    }

    @IBAction private func exit(segue: UIStoryboardSegue) {
        requestReview()
    }
}

// Action
extension CalculatorViewController {
    @objc private func segmentedControlValueChanged() {
        calculatedResult = nil
        calculatedResultLabel.text = nil

        enableCalculateButton()
        enableInfomationButton()
        enableTextField()
        loadDefaultTargetValue()
    }

    @objc private func textFieldEditingChanged() {
        enableCalculateButton()
    }

    @objc private func reloadButtonTouchUpInside() {
        fetchArticle()
    }

    @objc private func calculate() {
        guard let protein = Double(inputProteinTextField.text ?? ""),
              let fat = Double(inputFatTextField.text ?? "") else {
                return
              }

        switch selectedIndexType {
        case .ketogenicRatio:
            guard let carbohydrate = Double(inputCarbohydrateTextField.text ?? "") else { return }
            self.pfc = PFC(protein: protein, fat: fat, carbohydrate: carbohydrate)
            calculatedResult = pfc?.ketogenicRatio
        case .ketogenicIndex:
            guard let carbohydrate = Double(inputCarbohydrateTextField.text ?? "") else { return }
            self.pfc = PFC(protein: protein, fat: fat, carbohydrate: carbohydrate)
            calculatedResult = pfc?.ketogenicIndex
        case .ketogenicValue:
            guard let sugar = Double(inputSugarTextField.text ?? "") else { return }
            self.pfs =  PFS(protein: protein, fat: fat, sugar: sugar)
            calculatedResult = pfs?.ketogenicValue
        }

        guard let calculatedResult = calculatedResult else {
            let message = "入力されている値を確認してください"
            presentAlert(title: "計算", message: message, actionTitle: "OK")
            enableInfomationButton()
            return
        }

        // share用
        ketogenicCalculatedResult = calculatedResult
        shareResultButton.isEnabled = true

        // Label表示用
        calculatedResultLabel.text = String(round(calculatedResult * 100) / 100)
        enableInfomationButton()

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    @objc func transitfomationView() {
        guard let infomationVC
                = storyboard?
                .instantiateViewController(
                    withIdentifier: "InformationViewController"
                ) as? InformationViewController else {
                    return
                }

        switch selectedIndexType {
        case .ketogenicRatio, .ketogenicIndex:
            guard let pfc = pfc else { return }
            infomationVC.pfc = pfc
        case .ketogenicValue:
            guard let pfs = pfs else { return }
            infomationVC.pfs = pfs
        }
        infomationVC.currentKetogenicIndexType = selectedIndexType
        present(infomationVC, animated: true)
    }

    @objc func transitToSubscription() {
        guard let paywallVC =
                self
                .storyboard?
                .instantiateViewController(
                    withIdentifier: "PaywallViewController"
                ) as? PaywallViewController else {
            return
        }

        Task {
            await paywallVC.fetchPurchaseOffrings()
            present(paywallVC, animated: true)
        }
    }
}

// 各種バリデーションチェック
extension CalculatorViewController {
    private func enableCalculateButton() {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.calculateButton.isUserInteractionEnabled = false
            self?.calculateButton.backgroundColor = UIColor(named: "CalcButtonColor")
            self?.calculateButton.setTitle("Calc", for: .normal)
            self?.calculateButton
                .removeTarget(
                    self,
                    action: #selector(self?.transitfomationView),
                    for: .touchUpInside
                )
            self?.calculateButton
                .addTarget(
                    self,
                    action: #selector(self?.calculate),
                    for: .touchUpInside
                )
        } completion: {[weak self] _ in
            self?.calculateButton.isUserInteractionEnabled = true
        }
        calculateButton.isEnabled = isValidInTextToDouble()
        shareResultButton.isEnabled = false

        if calculateButton.isEnabled {
            calculateButton.layer.opacity = 1
        } else {
            calculateButton.layer.opacity = 0.5
        }
    }

    private func enableInfomationButton() {
        guard calculatedResult != nil else {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn) { [weak self] in
                self?.calculateButton.isUserInteractionEnabled = false
                self?.calculateButton.backgroundColor = UIColor(named: "CalcButtonColor")
                self?.calculateButton.setTitle("Calc", for: .normal)
                self?.calculateButton
                    .removeTarget(
                        self,
                        action: #selector(self?.transitfomationView),
                        for: .touchUpInside
                    )
                self?.calculateButton
                    .addTarget(
                        self,
                        action: #selector(self?.calculate),
                        for: .touchUpInside
                    )
            } completion: {[weak self] _ in
                self?.calculateButton.isUserInteractionEnabled = true
            }
            return
        }

        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.calculateButton.isUserInteractionEnabled = false
            self?.calculateButton.backgroundColor = UIColor(named: "Accent Color")
            self?.calculateButton.setTitle("Add", for: .normal)
            self?.calculateButton
                .removeTarget(
                    self,
                    action: #selector(self?.calculate),
                    for: .touchUpInside
                )
            self?.calculateButton
                .addTarget(
                    self,
                    action: #selector(self?.transitfomationView),
                    for: .touchUpInside
                )
        } completion: {[weak self] _ in
            self?.calculateButton.isUserInteractionEnabled = true
        }
    }

    // KetogenicIndexType別のTextFieldのEnableの切り替え
    private func enableTextField() {
        switch selectedIndexType {
        case .ketogenicRatio, .ketogenicIndex:
            inputCarbohydrateTextField.map {
                $0.isEnabled = true
                $0.layer.opacity = 1
            }

            inputSugarTextField.map {
                $0.isEnabled = false
                $0.layer.opacity = 0.5
            }

        case .ketogenicValue:
            inputCarbohydrateTextField.map {
                $0.isEnabled = false
                $0.layer.opacity = 0.5
            }

            inputSugarTextField.map {
                $0.isEnabled = true
                $0.layer.opacity = 1
            }
        }
    }

    // TextFieldの文字列がDoubleであるかのバリデーションチェック
    private func isValidInTextToDouble() -> Bool {
        let targetTextFields: [UITextField]
        switch selectedIndexType {
        case .ketogenicRatio, .ketogenicIndex:
            targetTextFields = [
                inputProteinTextField,
                inputFatTextField,
                inputCarbohydrateTextField
            ]
        case .ketogenicValue:
            targetTextFields = [
                inputProteinTextField,
                inputFatTextField,
                inputSugarTextField
            ]
        }

        return targetTextFields
            .map { $0.text ?? "" }
            .allSatisfy { Double($0) != nil }
    }
}

// API通信
extension CalculatorViewController {
    func fetchArticle() {
        apiClient = APIClient.shared
        apiClient?
            .fetchPost(for: accountStatus) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .failure(let error):
                    self?.articleFeedReloadButton.isHidden = false
                    print("error:\(error)")
                case .success(let contents):
                    DispatchQueue.global().async {
                        self?.fetchImage(from: contents)
                    }
                }
            }
        }
    }

    private func fetchImage(from wordpressContents: [WordPressContent]) {
        imageDownloader = ImageDownLoader.shared
        imageDownloader?
            .downloadImage(contents: wordpressContents,
                           completion: { result in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .failure(let error):
                        self?.articleFeedReloadButton.isHidden = false
                        self?.articleFeedLoadingActivityIndicator.stopAnimating()
                        print(error)
                    case .success(let articles):
                        self?.articles = articles

                        DispatchQueue.main.async { [weak self] in
                            self?.articleFeedReloadButton.isHidden = true
                            self?.articleFeedLoadingActivityIndicator.stopAnimating()
                            self?.articleFeedCollectionView.reloadData()
                        }
                    }
                }
            })
    }
}

extension CalculatorViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostFeedCollectionViewCell", for: indexPath)
        let article = articles[indexPath.row]

        if let cell = cell as? PostFeedCollectionViewCell {
            cell.configure(article: article)
        }
        return cell
    }
}

extension CalculatorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if articles.count > 0 {
            guard let articleURLString = articles[indexPath.row].wordPressContent.content?.postURL else { return }
            if let articleURL = URL(string: articleURLString) {
                let safariVC = SFSafariViewController(url: articleURL)
                present(safariVC, animated: true, completion: nil)
            }
        }
    }
}

extension CalculatorViewController {
    func requestReview() {
        var useCount: Int = settingUserDefaults.loadRequestReviewCount()
        if useCount > 100 {
            return
        } else if useCount == 20 || useCount == 50 || useCount == 100 {
            print("Reviewを表示します")
            if let scene = view.window?.windowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            useCount += 1
            settingUserDefaults.save(displayCount: useCount)
        }
    }
}

extension CalculatorViewController: UITextFieldDelegate {
    func settingTextFieldDelegate() {
        inputTextFields
            .forEach { $0.delegate = self }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        let currentTag = textField.tag
        var nextTag: Int
        if currentTag == 1 {
            switch selectedIndexType {
            case .ketogenicRatio: nextTag = currentTag + 1
            case .ketogenicIndex: nextTag = currentTag + 1
            case .ketogenicValue: nextTag = currentTag + 2
            }
        } else {
            nextTag = currentTag + 1
        }

        if let nextTextField = self.view.viewWithTag(nextTag) {
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
