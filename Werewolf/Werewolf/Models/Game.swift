//
//  Game.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import UIKit
import Combine
import MultipeerConnectivity
import SwiftUI


enum GameState {
    case night
    case day
}

enum GameSubstate {
    case pickingCard
    case waitingForOthers
    case pickingWinner
}


protocol GameDelegate: AnyObject {
    func cardDealt(card: Card)
    func playerJoined()
    func playersUpdated()
}

class Game {
    
    var card: Card!
    var cancellableBag = Set<AnyCancellable>()
    @ObservedObject var multipeer = GameMultipeerSession()
    weak var delegate: GameDelegate?
    var gameHost: Bool = false
    var players: [Player] = []
    var deck = Deck()
    
    init() {
        multipeer.delegate = self
    }
    
    func setupCard() {
        card = multipeer.currentCard
        card.objectWillChange.sink {
            print("card changed")
        }.store(in: &cancellableBag)
        
        card.$type.sink { value in
            let newCard = Card(name: value.name, type: value)
            self.delegate?.cardDealt(card: newCard)
        }.store(in: &cancellableBag)
    }
    
    func sendCard(index: Int) {
        if multipeer.getIDs().count > index {
            let id = multipeer.getIDs()[index]
            print("send card - (deal) \(id)")
            multipeer.sendCard(id: id, type: RequestType.dealCard)
        } else {
            let id = multipeer.getIDs()[0]
            print("send card - (deal) \(id)")
            multipeer.sendCard(id: id, type: RequestType.dealCard)
        }
       
    }
    
    func hostGame() {
        gameHost = true
        multipeer.host()
    }
    
    func joinGame() {
        gameHost = false
        multipeer.join()
    }
    
    func getPlayers() {
        multipeer.waitingForCards = true
        self.players.removeAll()
        for id in multipeer.getIDs() {
            DispatchQueue.main.async {
                self.multipeer.requestCard(id: id)
            }
        }
    }
}

extension Game: GameMultipeerSessionDelegate {
    func playerUpdated(player: Player) {
        print("player updated")
        dump(player)
        if let index = self.players.firstIndex(of: player) {
            self.players.insert(player, at: Int(index.description)!)
        } else {
            self.players.append(player)
        }
        print("session.count = \(multipeer.getIDs().count)")
        print("players.count = \(players.count)")
        if players.count == multipeer.getIDs().count {
            print("waiting for cards is false")
            multipeer.waitingForCards = false
            delegate?.playersUpdated()
        }
    }
    
    func gamePlayersJoined() {
        delegate?.playerJoined()
    }
}
