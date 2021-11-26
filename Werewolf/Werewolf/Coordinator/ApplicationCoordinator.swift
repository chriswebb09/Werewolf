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
        rootController = UINavigationController(rootViewController: lobbyVC)
        window.rootViewController = rootController
        window.makeKeyAndVisible()
        game.setupCard()
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
        lobbyVC.navigationController?.pushViewController(gameVC, animated: true)
    }
}

extension ApplicationCoordinator: GameViewControllerDelegate {
    func presentGamePlayers(navigationController: UIViewController) {
        if game.gameHost {
            DispatchQueue.main.async {
                self.game.getPlayers()
//                if self.gamePlayersVC.presenting {
//                    //self.gamePlayersVC.gamePlayers.append(contentsOf: self.game.getPlayers())
//                    //self.gamePlayersVC.collectionView.reloadData()
//                } else {
//                    //self.gamePlayersVC.gamePlayers = self.game.getPlayers()
//                    self.gamePlayersVC.presenting = true
//                    self.gameVC.present(self.gamePlayersVC, animated: true, completion: nil)
//                }
            }
        }
    }
    
    func sendCard(id index: Int) {
        game.sendCard(index: index)
    }
}

extension ApplicationCoordinator: GameDelegate {
    func playersUpdated() {
        print("app coordinator playersUpdated")
        DispatchQueue.main.async {
            if self.gamePlayersVC.presenting {
                print(self.game.players)
                self.gamePlayersVC.gamePlayers = self.game.players
                self.gamePlayersVC.presenting = true
                self.gamePlayersVC.collectionView.reloadData()
            } else {
                self.gamePlayersVC.gamePlayers = self.game.players
                self.gamePlayersVC.presenting = true
                
                self.gameVC.present(self.gamePlayersVC, animated: true, completion: nil)
                self.gamePlayersVC.collectionView.reloadData()
            }
            
        }
    }
    
    func playerJoined() {
        gameVC.playersJoined = true
    }
    
    func cardDealt(card: Card) {
        gameVC.imageView.image = card.type.image
    }
}
