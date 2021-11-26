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

enum GameSessionState {
    case host
    case player
    case unassigned
}


enum GameState {
    case night
    case day
    
    static func toggle(state: GameState) -> GameState {
        if state == .night {
            return .day
        } else {
            return .night
        }
    }
}

enum GameSubstateNight {
    case werewolfWakeup
    case minionWakeup
    case cupidWakeup
    case seerWakeup
}

enum GameSubstateDay {
    case morningUpdate
    case discussing
    case voting
    case results
}

//enum GameSubstate {
//    case pickingCard
//    case waitingForOthers
//    case pickingWinner
//}


protocol GameDelegate: AnyObject {
    func cardDealt(card: Card)
    func playerJoined()
    func playersUpdated(sessionState: GameSessionState)
    func werewolfTurnLogic()
}

class Game {
    
    var card: Card!
    var cancellableBag = Set<AnyCancellable>()
    @ObservedObject var multipeer = GameMultipeerSession()
    weak var delegate: GameDelegate?
    var gameHost: Bool = false
    var players: [Player] = []
    var deadPlayer: [Player] = []
    var deck: Deck!
    var gameSessionState: GameSessionState = .unassigned
    var gameState: GameState = .day
    var cupidIsDone: Bool = false
    
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
            DispatchQueue.main.async {
                self.delegate?.cardDealt(card: newCard)
            }
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
        self.gameSessionState = .host
        multipeer.host()
    }
    
    func joinGame() {
        gameHost = false
        self.gameSessionState = .player
        multipeer.join()
        setupCard()
    }
    
    func startGame(sessionState: GameSessionState) {
        print("func startGame(sessionState: GameSessionState)")
        switch sessionState {
        case .host:
            deck = Deck()
            deck.shuffleDeck()
            self.dealCards()
            self.playGame()
        case .player:
            break
        case .unassigned:
            break
        }
    }
    
    func playGame() {
        print("playGame")
       // startRound(state: gameState)
    }
    
    func startRound(state: GameState) {
        print("\n\nstartRound(state: GameState) \(state)")
        print("==========================================")
        switch state {
        case .night:
            nightLogic(substate: .werewolfWakeup)
        case .day:
            print("\n\ndayLogic(substate: GameSubstateDay) \(GameSubstateDay.morningUpdate)")
             print("==========================================")
            dayLogic(substate: .morningUpdate)
        }
        gameState = GameState.toggle(state: state)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.startRound(state: self.gameState)
        }
    }
    
    func dayLogic(substate: GameSubstateDay) {
       // print("\n\ndayLogic(substate: GameSubstateDay) \(substate)")
       // print("==========================================")
        switch substate {
        case .morningUpdate:
            print("someone died last night")
            dayLogic(substate: .discussing)
        case .discussing:
            print("discuss")
            dayLogic(substate: .voting)
        case .voting:
            print("vote")
            dayLogic(substate: .results)
        case .results:
            print("results")
        }
    }
    
    func nightLogic(substate: GameSubstateNight) {
        switch substate {
        case .werewolfWakeup:
            print("pick a victim")
            nightLogic(substate: .minionWakeup)
        case .minionWakeup:
            print("this is the werewolf")
            nightLogic(substate: .cupidWakeup)
        case .cupidWakeup:
            if cupidIsDone {
                nightLogic(substate: .seerWakeup)
            } else {
                print("match two players")
                cupidIsDone = true
            }
        case .seerWakeup:
            print("pick a user card to check")
        }
    }
    
    func dealCards() {
        print(multipeer.getIDs())
        let ids = multipeer.getIDs().filter { $0.displayName == multipeer.hostId }
        print(ids)
        for playerId in ids {
            let card = deck.deal()
            print(card.name)
            DispatchQueue.main.async {
                self.multipeer.send(card: card.type, id: playerId)
            }
        }
    }
    
    func getPlayers() {
        if self.card.type == .wolf {
            self.players.removeAll()
            for i in 0...4 {
                let card = Card.createCard(type: CardType.allCases[i])
                let player = Player(name: "test", deviceID: "test")
                player.card = card
                self.players.append(player)
            }
            
        } else {
            multipeer.waitingForCards = true
            self.players.removeAll()
            for id in multipeer.getIDs() {
                DispatchQueue.main.async {
                    self.multipeer.requestCard(id: id)
                }
            }
        }
        
    }
    
    func wereworlfTurn() {
        print("HERE")
        if self.card.type == .wolf {
            delegate?.werewolfTurnLogic()
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
            delegate?.playersUpdated(sessionState: gameSessionState)
        }
    }
    
    func gamePlayersJoined() {
        print("gameplayers joined")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.startGame(sessionState: self.gameSessionState)
            self.delegate?.playerJoined()
            self.startGame(sessionState: self.gameSessionState)
        }
    }
}
