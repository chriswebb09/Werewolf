//
//  GameNetwork.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import MultipeerConnectivity

class GameMultipeerSession: NSObject, ObservableObject {
    
    private let serviceType = "http"
    
    private let session: MCSession
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    private var serviceBrowser: MCNearbyServiceBrowser
    private var advertiserAssistant: MCNearbyServiceAdvertiser?
    
    @Published var currentCard: Card? = nil
    
    var connectedPeers: [MCPeerID] = []
    
    override init() {
        precondition(Thread.isMainThread)
        self.currentCard = Card(name: "Test", type: .seer)
        self.session = MCSession(peer: myPeerId)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        super.init()
        session.delegate = self
    }
    
    func host() {
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        advertiserAssistant = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: "http")
        advertiserAssistant?.delegate = self
        advertiserAssistant?.startAdvertisingPeer()
    }
    
    func join() {
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        DispatchQueue.main.async {
            if let appWindow = UIApplication.shared.keyWindow {
                let mcBrowserViewController = MCBrowserViewController(serviceType: "http", session: self.session)
                mcBrowserViewController.delegate = self
                mcBrowserViewController.view.backgroundColor = .white
                appWindow.rootViewController?.present(mcBrowserViewController, animated: true)
                appWindow.makeKeyAndVisible()
            }
        }
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func send(card: CardType) {
        precondition(Thread.isMainThread)
        Logger.log("Card: \(String(describing: card)) to \(self.session.connectedPeers.count) peers")
        if !session.connectedPeers.isEmpty {
            do {
                try session.send(card.rawValue.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                Logger.log("Error for sending: \(String(describing: error))")
            }
        }
    }
    
    func sendCard() {
        DispatchQueue.main.async {
            self.showCardSheet()
        }
    }
    
    private func showCardSheet() {
        let villagerAction = UIAlertAction(title: "Villager", style: .default, handler: { action in
            self.send(card: .villager)
        })
        let seerAction = UIAlertAction(title: "Seer", style: .default, handler: { action in
            self.send(card: .seer)
        })
        
        let werewolfAction = UIAlertAction(title: "Werewolf", style: .default, handler: { action in
            self.send(card: .wolf)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let alertController = UIAlertController(title: "Pick a card type", message: "", preferredStyle: .actionSheet)
        alertController.addAction(villagerAction)
        alertController.addAction(seerAction)
        alertController.addAction(werewolfAction)
        alertController.addAction(cancelAction)
        if let appWindow = UIApplication.shared.keyWindow {
            appWindow.rootViewController?.present(alertController, animated: true, completion: nil)
        }
        
    }
}

extension GameMultipeerSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        precondition(Thread.isMainThread)
        Logger.log("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        precondition(Thread.isMainThread)
        Logger.log("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, session)
    }
}

extension GameMultipeerSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        Logger.log("ServiceBrowser didNotStartBrowsingForPeers: \(error.localizedDescription)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        Logger.log("ServiceBrowser found peer: \(peerID)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Logger.log("ServiceBrowser lost peer: \(peerID)")
    }
}

extension GameMultipeerSession: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true) {
            print("Dismissing browser")
        }
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        session.disconnect()
        browserViewController.dismiss(animated: true)
    }
}

extension GameMultipeerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Logger.log("peer \(peerID) didChangeState: \(state.debugDescription)")
        switch state {
        case .connected:
            print("Connected to \(peerID)")
        case .connecting:
            print("Connecting \(peerID)")
        case .notConnected:
            print("not connected ")
        @unknown default:
            break
        }
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
            print(session.connectedPeers)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let string = String(data: data, encoding: .utf8), let card = CardType(rawValue: string) {
            Logger.log("didReceive card \(string)")
            DispatchQueue.main.async {
                self.currentCard?.type = card
            }
        } else {
            Logger.log("didReceive invalid value \(data.count) bytes")
        }
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        Logger.log("Receiving streams is not supported")
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        Logger.log("Receiving resources is not supported")
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        Logger.log("Receiving resources is not supported")
    }
}

extension MCSessionState: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .notConnected:
            return "notConnected"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        @unknown default:
            return "\(rawValue)"
        }
    }
}
