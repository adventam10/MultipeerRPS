//
//  RPSState.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/22.
//

import Foundation

enum RPSState: Equatable {
    case notConnected
    case connected(displayName: String)
    case waiting(displayName: String)
    case waitingYou(displayName: String)
}
