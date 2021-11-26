//
//  ApplicationCoordinator.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import UIKit
import Combine
import MultipeerConnectivity
import SwiftUI

final class ApplicationCoordinator: Coordinator {
    
    var window: UIWindow
    var rootController: UIViewController!
    var card: Card!
    var game: Game = Game()
    
    // MARK: ViewControllers
    
    let lobbyVC = LobbyViewController()
    let gameVC = GameViewController()
    let gamePlayersVC = GamePlayersViewController()
    
    // MARK: Initialize
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        lobbyVC.delegate = self
        gameVC.delegate = self
        game.delegate = self
        gamePlayersVC.delegate = self
        rootController = UINavigationController(rootViewController: lobbyVC)
        window.rootViewController = rootController
        window.makeKeyAndVisible()
    }
}

extension ApplicationCoordinator: LobbyViewControllerDelegate {
    func hostGame() {
        game.gameHost = true
        game.hostGame()
    }
    
    func joinGame() {
        game.joinGame()
    }
    
    func goToGame() {
        gameVC.isHost = game.gameHost
        lobbyVC.navigationController?.pushViewController(gameVC, animated: true)
    }
}

extension ApplicationCoordinator: GameViewControllerDelegate {
    func presentGamePlayers(navigationController: UIViewController) {
        if game.gameHost {
            DispatchQueue.main.async {
                self.game.getPlayers()
            }
        }
    }
    
    func sendCard(id index: Int) {
        game.sendCard(index: index)
    }
}

extension ApplicationCoordinator: GameDelegate {
    func playersUpdated(sessionState: GameSessionState) {
        print(sessionState)
        var gamePlayers = game.players.filter { game.deadPlayer.contains($0) }
        let deadGamePlayers = game.players.filter { !game.deadPlayer.contains($0) }
        deadGamePlayers.map { $0.playerInGame = false }
        gamePlayers.append(contentsOf: deadGamePlayers)
        if sessionState == .host || game.card.type == .wolf {
            DispatchQueue.main.async {
                self.gamePlayersVC.isWerewolf = self.game.card.type == .wolf
                if self.gamePlayersVC.presenting {
                    print(gamePlayers)
                    self.gamePlayersVC.gamePlayers = gamePlayers
                    self.gamePlayersVC.presenting = true
                    self.gamePlayersVC.collectionView.reloadData()
                } else {
                    self.gamePlayersVC.gamePlayers = gamePlayers
                    self.gamePlayersVC.presenting = true
                    self.gameVC.present(self.gamePlayersVC, animated: true, completion: nil)
                    self.gamePlayersVC.collectionView.reloadData()
                }
            }
        }
    }
    
    func werewolfTurnLogic() {
        self.game.getPlayers()
        self.gamePlayersVC.gamePlayers = self.game.players
        self.gamePlayersVC.presenting = true
        self.gamePlayersVC.isWerewolf = true
        self.gameVC.present(self.gamePlayersVC, animated: true, completion: nil)
        self.gamePlayersVC.collectionView.reloadData()
    }
    
    func playerJoined() {
        gameVC.playersJoined = true
    }
    
    func cardDealt(card: Card) {
        gameVC.imageView.image = card.type.image
        if card.type == .wolf {
            game.wereworlfTurn()
        }
    }
}

extension ApplicationCoordinator: GamePlayersViewControllerDelegate {
    func kill(player: Player) {
        game.deadPlayer.append(player)
    }
}
