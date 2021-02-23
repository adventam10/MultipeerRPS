//
//  ViewController.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/22.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet private weak var appDescriptionLabel: UILabel!
    @IBOutlet private weak var playButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem?.title = NSLocalizedString("setting", comment: "")
        appDescriptionLabel.text = NSLocalizedString("app_description", comment: "")
        playButton.setTitle(NSLocalizedString("play", comment: ""), for: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let setting = segue.destination as? SettingTableViewController {
            setting.presentationModel = .init(userSettingRepository: UserSettingRepositoryImp())
        } else if let rps = segue.destination as? RPSViewController {
            rps.presentationModel = .init(userSettingRepository: UserSettingRepositoryImp(), p2pManager: RPSP2PManagerImp())
        }
    }
}
