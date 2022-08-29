//
//  AboutAppTableViewController.swift
//  KetoCalculator
//
//  Created by 山田　天星 on 2022/03/23.
//

import UIKit
import SafariServices

class AboutAppTableViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private var versionString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionString = "Version: \(version)"
        }
    }

    private func privacypolicyTouchUpInside() {
        let privacypolicyURL = "https://ytoaster.com/ketocalculator/"
        let url = URL(string: privacypolicyURL)
        if let url = url {
            let privacypolicyVC = SFSafariViewController(url: url)
            present(privacypolicyVC, animated: true, completion: nil)
        }
    }
}

extension AboutAppTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0: return
        case 1: return
        case 2: privacypolicyTouchUpInside()
        default: return
        }
    }
}

extension AboutAppTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aboutAppCellIdentifier = "aboutAppCell"
        let expressionCellIdentifier = "expressionCell"
        let privacyPolicyCellIdentifier = "privacyPolicyCell"
        let aboutVersionCellIdentifier = "aboutVersionCell"
        var identifier = ""

        switch indexPath.row {
        case 0: identifier = aboutAppCellIdentifier
        case 1: identifier = expressionCellIdentifier
        case 2: identifier = privacyPolicyCellIdentifier
        case 3: identifier = aboutVersionCellIdentifier
        default: fatalError()
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
            fatalError()
        }
        if cell.reuseIdentifier == aboutVersionCellIdentifier {
            guard let versionString = versionString else { return cell }
            cell.detailTextLabel?.text = versionString
        }
        return cell
    }
}
