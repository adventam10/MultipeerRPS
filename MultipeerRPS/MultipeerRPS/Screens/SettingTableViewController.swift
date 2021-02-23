//
//  SettingTableViewController.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/22.
//

import UIKit

final class SettingTableViewController: UITableViewController {

    @IBOutlet private weak var resetDataTitleLabel: UILabel!
    @IBOutlet private weak var accountNameTitleLabel: UILabel!
    @IBOutlet private weak var accountNameLabel: UILabel!
    @IBOutlet private weak var privacyPolicyTitleLabel: UILabel!
    @IBOutlet private weak var appVersionTitleLabel: UILabel!
    @IBOutlet private weak var appVersionLabel: UILabel!

    var presentationModel: SettingPresentationModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        accountNameLabel.text = presentationModel.accountName
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editAccount = segue.destination as? EditAccountNameTableViewController {
            editAccount.presentationModel = presentationModel.makeEditAccountNamePresentationModel()
        }
    }

    private func setupViews() {
        title = presentationModel.screenTitle
        accountNameLabel.text = presentationModel.accountName
        accountNameTitleLabel.text = presentationModel.menuTitleAccountName
        resetDataTitleLabel.text = presentationModel.menuTitleResetData
        privacyPolicyTitleLabel.text = presentationModel.menuTitlePrivacyPolicy
        appVersionTitleLabel.text = presentationModel.menuTitleAppVersion
        appVersionLabel.text = presentationModel.appVersion
    }
}

extension SettingTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch presentationModel.menu(at: indexPath) {
        case .accountName:
            break
        case .resetData:
            showAlert(message: NSLocalizedString("reset_alert_message", comment: ""), okAction: { [weak self] in
                self?.presentationModel.resetResultCount()
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }) { [weak self] in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }
        case .privacyPolicy:
            if let url = URL(string: "https://adventam10.github.io/DNAConverter-iOS/PrivacyPolicy/PrivacyPolicy") {
                UIApplication.shared.open(url)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        case .appVersion:
            break
        default:
            assertionFailure("想定外のメニュー")
        }
    }
}
