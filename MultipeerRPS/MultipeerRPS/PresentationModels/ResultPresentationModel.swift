//
//  ResultPresentationModel.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/23.
//

import Foundation
import class UIKit.UIColor

final class ResultPresentationModel {

    private let result: RPSResult
    private let moves: (mine: RPSMove?, opponents: RPSMove?)

    var isWinner: Bool {
        return result == .win
    }

    var myMoveImageName: String {
        return imageName(move: moves.mine)
    }

    var opponentsMoveImageName: String {
        return imageName(move: moves.opponents)
    }

    var myMoveColor: UIColor {
        return color(move: moves.mine)
    }

    var opponentsMoveColor: UIColor {
        return color(move: moves.opponents)
    }

    var resultImageName: String {
        switch result {
        case .win:
            return "win"
        case .lose:
            return "lose"
        case .draw:
            return "draw"
        }
    }

    init(result: RPSResult,
         moves: (mine: RPSMove?, opponents: RPSMove?)) {
        self.result = result
        self.moves = moves
    }

    private func imageName(move: RPSMove?) -> String {
        switch move {
        case .rock:
            return "rock"
        case .paper:
            return "paper"
        case .scissors:
            return "scissors"
        default:
            return ""
        }
    }

    private func color(move: RPSMove?) -> UIColor {
        switch move {
        case .rock:
            return .systemBlue
        case .paper:
            return .systemYellow
        case .scissors:
            return .systemRed
        default:
            return .clear
        }
    }
}
