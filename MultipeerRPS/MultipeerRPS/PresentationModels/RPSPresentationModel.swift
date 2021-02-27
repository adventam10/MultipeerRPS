//
//  RPSPresentationModel.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/22.
//

import Foundation
import class MultipeerConnectivity.MCBrowserViewController
import enum MultipeerConnectivity.MCSessionState
import class MultipeerConnectivity.MCPeerID

final class RPSPresentationModel {

    var moves: (mine: RPSMove?, opponents: RPSMove?) = (nil, nil)
    var state: RPSState = .notConnected

    let winTitle = NSLocalizedString("win_title", comment: "")
    let loseTitle = NSLocalizedString("lose_title", comment: "")
    let drawTitle = NSLocalizedString("draw_title", comment: "")
    let dropDescription = NSLocalizedString("drop_description", comment: "")
    let searchButtonTitle = NSLocalizedString("search", comment: "")

    private let userSettingRepository: UserSettingRepository
    private let p2pManager: RPSP2PManager
    private (set) var resultCount: ResultCount

    private var peerID: MCPeerID {
        let newDisplayName = userSettingRepository.accountName
        guard let id = userSettingRepository.peerID else {
            return refreshPeerID(displayName: newDisplayName)
        }
        if id.displayName != newDisplayName {
            return refreshPeerID(displayName: newDisplayName)
        }
        return id
    }

    var isConnected: Bool {
        return p2pManager.isConnected
    }

    var opponentName: String {
        switch state {
        case .connected(let displayName), .waiting(let displayName), .waitingYou(let displayName):
            return displayName
        case .notConnected:
            return ""
        }
    }

    var canBattle: Bool {
        return moves.mine != nil && moves.opponents != nil
    }

    var displayState: String {
        switch state {
        case .notConnected:
            return NSLocalizedString("state_notConnected", comment: "")
        case .connected(let displayName):
            return String(format: NSLocalizedString("state_connected", comment: ""), displayName)
        case .waiting(let displayName):
            return String(format: NSLocalizedString("state_waiting", comment: ""), displayName)
        case .waitingYou(let displayName):
            return String(format: NSLocalizedString("state_waiting_you", comment: ""), displayName)
        }
    }

    init(userSettingRepository: UserSettingRepository,
         p2pManager: RPSP2PManager) {
        self.p2pManager = p2pManager
        self.userSettingRepository = userSettingRepository
        self.resultCount = userSettingRepository.resultCount
    }

    func battle(moves: (mine: RPSMove?, opponents: RPSMove?)) -> RPSResult {
        switch moves {
        case (.rock, .rock), (.paper, .paper), (.scissors, .scissors):
            return .draw
        case (.rock, .paper), (.paper, .scissors), (.scissors, .rock):
            return .lose
        case (.rock, .scissors), (.paper, .rock), (.scissors, .paper):
            return .win
        case (nil, _):
            return .lose
        case (_, nil):
            return .win
        }
    }

    func countUp(result: RPSResult) {
        switch result {
        case .win:
            resultCount.win += 1
        case .lose:
            resultCount.lose += 1
        case .draw:
            resultCount.draw += 1
        }
        userSettingRepository.updateResultCount(resultCount)
    }

    func resetMoves() {
        moves = (nil, nil)
    }

    func updateWaitingState() {
        switch moves {
        case (nil, nil):
            state = .connected(displayName: opponentName)
        case (nil, _):
            state = .waitingYou(displayName: opponentName)
        case (_, nil):
            state = .waiting(displayName: opponentName)
        case (.some(_), .some(_)):
            break
        }
    }

    func makeResultPresentationModel(result: RPSResult) -> ResultPresentationModel {
        return .init(result: result, moves: moves)
    }

    private func refreshPeerID(displayName: String) -> MCPeerID {
        let peerID = MCPeerID(displayName: displayName)
        userSettingRepository.updatePeerID(peerID)
        return peerID
    }
}

extension RPSPresentationModel {

    func setupP2PManager(didReceiveMoveHandler: @escaping ((RPSMove, String) -> ()),
                         didChangeStateHandler: @escaping ((MCSessionState, String) -> ())) {
        p2pManager.setup(peerID: peerID,
                         didReceiveMoveHandler: didReceiveMoveHandler,
                         didChangeStateHandler: didChangeStateHandler)
    }

    func sendMove(_ move: RPSMove) {
        p2pManager.sendMove(move)
    }

    func stop() {
        p2pManager.stop()
    }

    func startAdvertisingPeer() {
        p2pManager.startAdvertisingPeer()
    }

    func stopAdvertisingPeer() {
        p2pManager.stopAdvertisingPeer()
    }

    func makeBrowserViewController() -> MCBrowserViewController? {
        return p2pManager.makeBrowserViewController()
    }
}
