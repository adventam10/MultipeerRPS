//
//  RPSViewController.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/22.
//

import UIKit
import MultipeerConnectivity
import GoogleMobileAds

final class RPSViewController: UIViewController {

    @IBOutlet private weak var bannerView: GADBannerView!
    @IBOutlet private weak var drawTitleLabel: UILabel!
    @IBOutlet private weak var loseTitleLabel: UILabel!
    @IBOutlet private weak var winTitleLabel: UILabel!
    @IBOutlet private weak var dropLabel: UILabel!
    @IBOutlet private weak var drawCountLabel: UILabel!
    @IBOutlet private weak var loseCountLabel: UILabel!
    @IBOutlet private weak var winCountLabel: UILabel!
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var paperView: UIView! {
        didSet {
            let dragInteraction = UIDragInteraction(delegate: self)
            dragInteraction.isEnabled = true
            paperView.addInteraction(dragInteraction)
        }
    }
    @IBOutlet private weak var scissorsView: UIView! {
        didSet {
            let dragInteraction = UIDragInteraction(delegate: self)
            dragInteraction.isEnabled = true
            scissorsView.addInteraction(dragInteraction)
        }
    }
    @IBOutlet private weak var rockView: UIView! {
        didSet {
            let dragInteraction = UIDragInteraction(delegate: self)
            dragInteraction.isEnabled = true
            rockView.addInteraction(dragInteraction)
        }
    }
    @IBOutlet private weak var dropAreaView: UIView! {
        didSet {
            dropAreaView.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    private var browseButton: UIBarButtonItem!

    var presentationModel: RPSPresentationModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presentationModel.setupP2PManager { [weak self] (move, displayName) in
            self?.presentationModel.moves.opponents = move
            self?.presentationModel.updateWaitingState()
            self?.updateState()
            self?.battle()
        } didChangeStateHandler: { [weak self] (state, displayName) in
            switch state {
            case .connected:
                self?.presentationModel.state = .connected(displayName: displayName)
            case .notConnected:
                self?.presentationModel.state = .notConnected
                self?.presentationModel.resetMoves()
            default:
                break
            }
            self?.updateState()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if presentedViewController == nil {
            // たまに切れない時があるのでここで切断
            presentationModel.stop()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ResultViewController,
           let result = sender as? RPSResult {
            vc.presentationModel = presentationModel.makeResultPresentationModel(result: result)
        }
    }

    @objc private func browse(_ sender: Any) {
        presentationModel.startAdvertisingPeer()
        if let vc = presentationModel.makeBrowserViewController() {
            vc.delegate = self
            present(vc, animated: true)
        }
    }

    private func sendMove(_ move: Int) {
        guard let move = RPSMove(rawValue: move) else {
            return
        }
        presentationModel.sendMove(move)
        presentationModel.moves.mine = move
        presentationModel.updateWaitingState()
        updateState()
    }

    private func setupViews() {
        winTitleLabel.text = presentationModel.winTitle
        loseTitleLabel.text = presentationModel.loseTitle
        drawTitleLabel.text = presentationModel.drawTitle
        dropLabel.text = presentationModel.dropDescription
        browseButton = UIBarButtonItem(title: presentationModel.searchButtonTitle, style: .done, target: self, action: #selector(browse(_:)))
        navigationItem.rightBarButtonItem = browseButton
        updateState()
        updateCount()

        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
}

extension RPSViewController {

    private func updateState() {
        switch presentationModel.state {
        case .connected, .waitingYou:
            dropAreaView.isUserInteractionEnabled = true
            dropAreaView.alpha = 1.0
        case .notConnected, .waiting:
            dropAreaView.isUserInteractionEnabled = false
            dropAreaView.alpha = 0.3
        }
        stateLabel.text = presentationModel.displayState
        browseButton.isEnabled = presentationModel.state == .notConnected
        dropLabel.isHidden = presentationModel.state == .notConnected
    }

    private func updateCount() {
        winCountLabel.text = "\(presentationModel.resultCount.win)"
        loseCountLabel.text = "\(presentationModel.resultCount.lose)"
        drawCountLabel.text = "\(presentationModel.resultCount.draw)"
    }

    private func battle() {
        guard presentationModel.canBattle else {
            return
        }
        let result = presentationModel.battle(moves: presentationModel.moves)
        presentationModel.countUp(result: result)
        performSegue(withIdentifier: "toResult", sender: result)
        presentationModel.resetMoves()
        presentationModel.updateWaitingState()
        updateState()
        updateCount()
    }
}

extension RPSViewController: MCBrowserViewControllerDelegate {

    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
        presentationModel.stopAdvertisingPeer()
    }

    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
        presentationModel.stopAdvertisingPeer()
    }

    func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
        return true
    }
}

extension RPSViewController: UIDropInteractionDelegate {

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.items.filter { $0.itemProvider.canLoadObject(ofClass: NSString.self) }.forEach { item in
            item.itemProvider.loadObject(ofClass: NSString.self) { [weak self] (object, error) in
                if let string = object as? NSString {
                    DispatchQueue.main.async {
                        self?.sendMove(string.integerValue)
                        self?.battle()
                    }
                }
            }
        }
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return true
    }
}

extension RPSViewController: UIDragInteractionDelegate {

    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let tag = interaction.view?.tag else {
            return []
        }
        let text = "\(tag)" as NSString
        return [UIDragItem(itemProvider: NSItemProvider(object: text))]
    }
}
