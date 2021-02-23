//
//  UserSettingRepository.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/22.
//

import Foundation
import class UIKit.UIDevice

typealias ResultCount = (win: Int, lose: Int, draw: Int)

protocol UserSettingRepository {
    var displayName: String? { get }
    func updateDisplayName(_ displayName: String?)
    var resultCount: ResultCount { get }
    func updateResultCount(_ resultCount: ResultCount)
}

extension UserSettingRepository {

    var accountName: String {
        guard let name = displayName else {
            return UIDevice.current.name
        }
        return name.isEmpty ? UIDevice.current.name : name
    }
}

struct UserSettingRepositoryImp: UserSettingRepository {

    enum Key: String {
        case displayName = "RPS_USER_DISPLAY_NAME"
        case winCount = "RPS_WIN_COUNT"
        case loseCount = "RPS_LOSE_COUNT"
        case drawCount = "RPS_DRAW_COUNT"
    }

    private let userDefaults = UserDefaults.standard

    var displayName: String? {
        return userDefaults.string(forKey: Key.displayName.rawValue)
    }

    func updateDisplayName(_ displayName: String?) {
        userDefaults.set(displayName, forKey: Key.displayName.rawValue)
    }

    var resultCount: ResultCount {
        let win = userDefaults.integer(forKey: Key.winCount.rawValue)
        let lose = userDefaults.integer(forKey: Key.loseCount.rawValue)
        let draw = userDefaults.integer(forKey: Key.drawCount.rawValue)
        return (win: win, lose: lose, draw: draw)
    }

    func updateResultCount(_ resultCount: ResultCount) {
        userDefaults.set(resultCount.win, forKey: Key.winCount.rawValue)
        userDefaults.set(resultCount.lose, forKey: Key.loseCount.rawValue)
        userDefaults.set(resultCount.draw, forKey: Key.drawCount.rawValue)
    }
}
