//
//  ViewController.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/22.
//

import UIKit
import GoogleMobileAds

final class ViewController: UIViewController {

    @IBOutlet private weak var bannerView: GADBannerView!
    @IBOutlet private weak var appDescriptionLabel: UILabel!
    @IBOutlet private weak var playButton: UIButton!

    private var interstitial: GADInterstitialAd?
    private var isShownInterstitial = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem?.title = NSLocalizedString("setting", comment: "")
        appDescriptionLabel.text = NSLocalizedString("app_description", comment: "")
        playButton.setTitle(NSLocalizedString("play", comment: ""), for: .normal)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())

        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest()) { [weak self] (ad, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            self?.interstitial = ad
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isShownInterstitial {
            if let interstitial = interstitial {
                interstitial.present(fromRootViewController: self)
            }
        }
        isShownInterstitial = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let setting = segue.destination as? SettingTableViewController {
            setting.presentationModel = .init(userSettingRepository: UserSettingRepositoryImp())
        } else if let rps = segue.destination as? RPSViewController {
            rps.presentationModel = .init(userSettingRepository: UserSettingRepositoryImp(), p2pManager: RPSP2PManagerImp())
            isShownInterstitial = true
        }
    }
}
