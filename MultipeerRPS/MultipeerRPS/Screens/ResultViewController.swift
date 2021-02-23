//
//  ResultViewController.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/23.
//

import UIKit
import StoreKit

final class ResultViewController: UIViewController {

    @IBOutlet private weak var opponentsMoveView: UIView!
    @IBOutlet private weak var myMoveView: UIView!
    @IBOutlet private weak var opponentsMoveImageView: UIImageView!
    @IBOutlet private weak var myMoveImageView: UIImageView!
    @IBOutlet private weak var resultImageView: UIImageView!

    var presentationModel: ResultPresentationModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.dismiss(animated: true) { [unowned self] in
                if self.presentationModel.isWinner {
                    SKStoreReviewController.requestReview()
                }
            }
        }
    }

    private func setupViews() {
        myMoveImageView.image = UIImage(named: presentationModel.myMoveImageName)
        opponentsMoveImageView.image = UIImage(named: presentationModel.opponentsMoveImageName)
        opponentsMoveView.backgroundColor = presentationModel.opponentsMoveColor
        myMoveView.backgroundColor = presentationModel.myMoveColor
        resultImageView.image = UIImage(named: presentationModel.resultImageName)
    }
}
