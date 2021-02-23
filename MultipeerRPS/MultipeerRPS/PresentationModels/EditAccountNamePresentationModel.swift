//
//  EditAccountNamePresentationModel.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/22.
//

import Foundation

final class EditAccountNamePresentationModel {

    private let userSettingRepository: UserSettingRepository

    let screenTitle = NSLocalizedString("account_name", comment: "")

    var accountName: String {
        return userSettingRepository.accountName
    }

    init(userSettingRepository: UserSettingRepository) {
        self.userSettingRepository = userSettingRepository
    }

    func updateAccountName(_ name: String?) {
        userSettingRepository.updateDisplayName(name)
    }
}
