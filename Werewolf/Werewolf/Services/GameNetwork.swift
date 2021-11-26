//
//  GameNetwork.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import MultipeerConnectivity

enum RequestType: String {
    case sendCard
    case dealCard
    case sendHostId
}

protocol GameMultipeerSessionDelegate: AnyObject {
    func gamePlayersJoined()
    func playerUpdated(player: Player)
}

class GameMultipeerSession: NSObject, ObservableObject {
    
    weak var delegate: GameMultipeerSessionDelegate?
    
    private let serviceType = "http"
    private let session: MCSession
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    private var serviceBrowser: MCNearbyServiceBrowser
    private var advertiserAssistant: MCNearbyServiceAdvertiser?
    private var isHost: Bool = false
    var hostId: String = ""
    @Published var currentCard: Card? = nil
    var connectedPeers: [MCPeerID] = []
    var waitingForCards: Bool = false
    
    override init() {
        precondition(Thread.isMainThread)
        currentCard = Card(name: CardType.blank.name, type: .blank)
        session = MCSession(peer: myPeerId)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        super.init()
        session.delegate = self
    }
    
    func host() {
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        advertiserAssistant = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: "http")
        advertiserAssistant?.delegate = self
        advertiserAssistant?.startAdvertisingPeer()
        self.isHost = true
        hostId = myPeerId.displayName
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
                self.isHost = false
            }
        }
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func send(card: CardType, id: MCPeerID) {
        precondition(Thread.isMainThread)
        Logger.log("Card: \(String(describing: card)) to \(id) peers")
        if !session.connectedPeers.isEmpty {
            do {
                try session.send(card.rawValue.data(using: .utf8)!, toPeers: [id], with: .reliable)
            } catch {
                Logger.log("Error for sending: \(String(describing: error))")
            }
        }
    }
    
    func requestCard(id: MCPeerID) {
        precondition(Thread.isMainThread)
        print("requesting card from \(id)")
        if !session.connectedPeers.isEmpty {
            do {
                print(RequestType.sendCard.rawValue)
                try session.send(RequestType.sendCard.rawValue.data(using: .utf8)!, toPeers: [id], with: .reliable)
            } catch {
                Logger.log("Error for sending: \(String(describing: error))")
            }
        }
    }
    
    func sendHostID(hostId: MCPeerID, id: MCPeerID) {
        precondition(Thread.isMainThread)
        if !session.connectedPeers.isEmpty {
            do {
                let sendData = RequestType.sendHostId.rawValue + " " + hostId.displayName
                try session.send(sendData.data(using: .utf8)!, toPeers: [id], with: .reliable)
            } catch {
                Logger.log("Error for sending: \(String(describing: error))")
            }
        }
    }
    
    
    func sendCard(id: MCPeerID, type: RequestType) {
        print(type)
        if type == .sendCard {
            self.send(card: currentCard!.type, id: id)
        } else if type == .dealCard {
            DispatchQueue.main.async {
                self.showCardSheet(id: id)
            }
        }
    }
    
    func getIDs() -> [MCPeerID]  {
        return connectedPeers
    }
    
    private func showCardSheet(id: MCPeerID) {
        let villagerAction = UIAlertAction(title: "Villager", style: .default, handler: { action in
            self.send(card: .villager, id: id)
        })
        let seerAction = UIAlertAction(title: "Seer", style: .default, handler: { action in
            self.send(card: .seer, id: id)
        })
        
        let werewolfAction = UIAlertAction(title: "Werewolf", style: .default, handler: { action in
            self.send(card: .wolf, id: id)
        })
        
        let tannerAction = UIAlertAction(title: "Tanner", style: .default, handler: { action in
            self.send(card: .tanner, id: id)
        })
        
        let cupidAction = UIAlertAction(title: "Cupid", style: .default, handler: { action in
            self.send(card: .cupid, id: id)
        })
        
        let bodyguard = UIAlertAction(title: "Bodyguard", style: .default, handler: { action in
            self.send(card: .bodyguard, id: id)
        })
        
        let cursed = UIAlertAction(title: "Cursed", style: .default, handler: { action in
            self.send(card: .cursed, id: id)
        })
        
        let hunter = UIAlertAction(title: "Hunter", style: .default, handler: { action in
            self.send(card: .hunter, id: id)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let alertController = UIAlertController(title: "Pick a card type", message: "", preferredStyle: .actionSheet)
        alertController.addAction(villagerAction)
        alertController.addAction(seerAction)
        alertController.addAction(werewolfAction)
        alertController.addAction(tannerAction)
        alertController.addAction(cupidAction)
        alertController.addAction(bodyguard)
        alertController.addAction(cursed)
        alertController.addAction(hunter)
        
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
            if isHost {
                print("IS HOST")
                DispatchQueue.main.async {
                    self.sendHostID(hostId: self.myPeerId, id: peerID)
                }
            }
            
            DispatchQueue.main.async {
                self.delegate?.gamePlayersJoined()
            }
            
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
        print("func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)")
        if let string = String(data: data, encoding: .utf8), let requestType = RequestType(rawValue: string) {
            print(requestType)
            if self.isHost {
                
            } else {
                DispatchQueue.main.async {
                    self.send(card: self.currentCard!.type, id: peerID)
                }
            }
        } else if let string = String(data: data, encoding: .utf8), let card = CardType(rawValue: string) {
            print("recieved card")
            if self.isHost || currentCard?.type == .wolf {
                // update
                let player = Player(name: "Player " + peerID.displayName, deviceID: peerID.displayName)
                player.card = Card(name: card.name, type: card)
                self.delegate?.playerUpdated(player: player)
            } else {
                DispatchQueue.main.async {
                    self.currentCard?.type = card
                }
            }
        } else if let string = String(data: data, encoding: .utf8) {
            print(string)
            let components = string.components(separatedBy: " ")
            if let requestType = RequestType(rawValue: components[0]), requestType == .sendHostId {
                self.hostId = components[1]
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
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        print("session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void)")
        certificateHandler(true)
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
