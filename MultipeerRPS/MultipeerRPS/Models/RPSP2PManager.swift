//
//  RPSP2PManager.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/22.
//

import Foundation
import MultipeerConnectivity

protocol RPSP2PManager {
    func setup(displayName: String,
               didReceiveMoveHandler: @escaping ((RPSMove, String) -> ()),
               didChangeStateHandler: @escaping ((MCSessionState, String) -> ()))
    func sendMove(_ move: RPSMove)
    func stop()
    func startAdvertisingPeer()
    func stopAdvertisingPeer()
    func makeBrowserViewController() -> MCBrowserViewController
    var isConnected: Bool { get }
}

final class RPSP2PManagerImp: NSObject, RPSP2PManager {

    private let serviceType = "p2p-rps"
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!

    private var didChangeStateHandler: ((MCSessionState, String) -> ())?
    private var didReceiveMoveHandler: ((RPSMove, String) -> ())?

    var isConnected: Bool {
        return !session.connectedPeers.isEmpty
    }

    func setup(displayName: String,
               didReceiveMoveHandler: @escaping ((RPSMove, String) -> ()),
               didChangeStateHandler: @escaping ((MCSessionState, String) -> ())) {
        if let advertiser = advertiser {
            advertiser.stopAdvertisingPeer()
        }
        if let session = session {
            session.disconnect()
        }

        self.didReceiveMoveHandler = didReceiveMoveHandler
        self.didChangeStateHandler = didChangeStateHandler

        let peerID = MCPeerID(displayName: displayName)
        session = MCSession(peer: peerID)
        session.delegate = self

        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
    }

    func sendMove(_ move: RPSMove) {
        guard let data = "\(move.rawValue)".data(using: .utf8) else {
            assertionFailure("データ送信非対応")
            return
        }
        do {
            // iOS12で受信できない
//            let data = try JSONEncoder().encode(move)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func stop() {
        advertiser.stopAdvertisingPeer()
        session.disconnect()
    }

    func startAdvertisingPeer() {
        advertiser.startAdvertisingPeer()
    }

    func stopAdvertisingPeer() {
        advertiser.stopAdvertisingPeer()
    }

    func makeBrowserViewController() -> MCBrowserViewController {
        return .init(serviceType: serviceType, session: session)
    }
}

extension RPSP2PManagerImp: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.didChangeStateHandler?(state, peerID.displayName)
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let string = String(data: data, encoding: .utf8),
              let rawValue = Int(string),
              let move = RPSMove(rawValue: rawValue) else {
            assertionFailure("データ受信非対応")
            return
        }
        DispatchQueue.main.async {
            self.didReceiveMoveHandler?(move, peerID.displayName)
        }
        // iOS12で受信できない
//        do {
//            let move = try JSONDecoder().decode(RPSMove.self, from: data)
//            DispatchQueue.main.async {
//                self.didReceiveMoveHandler?(move, peerID.displayName)
//            }
//        } catch let error {
//            print(error.localizedDescription)
//        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        assertionFailure("非対応")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        assertionFailure("非対応")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        assertionFailure("非対応")
    }
}

extension RPSP2PManagerImp: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
        // １対１想定なので停止
        stopAdvertisingPeer()
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
}
