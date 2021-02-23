//
//  SettingPresentationModel.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/22.
//

import Foundation

final class SettingPresentationModel {

    enum Menu {
        case accountName
        case resetData
        case privacyPolicy
        case appVersion
    }

    let screenTitle = NSLocalizedString("setting", comment: "")
    let menuTitleAccountName = NSLocalizedString("account_name", comment: "")
    let menuTitleResetData = NSLocalizedString("reset_data", comment: "")
    let menuTitlePrivacyPolicy = NSLocalizedString("privacy_policy", comment: "")
    let menuTitleAppVersion = NSLocalizedString("app_version", comment: "")

    var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    let userSettingRepository: UserSettingRepository

    var accountName: String {
        return userSettingRepository.accountName
    }

    init(userSettingRepository: UserSettingRepository) {
        self.userSettingRepository = userSettingRepository
    }

    func menu(at indexPath: IndexPath) -> Menu? {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                return .accountName
            case 1:
                return .resetData
            default:
                return nil
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                return .privacyPolicy
            case 1:
                return .appVersion
            default:
                return nil
            }
        }
        return nil
    }

    func resetResultCount() {
        userSettingRepository.updateResultCount((0, 0, 0))
    }

    func makeEditAccountNamePresentationModel() -> EditAccountNamePresentationModel {
        return .init(userSettingRepository: UserSettingRepositoryImp())
    }
}
