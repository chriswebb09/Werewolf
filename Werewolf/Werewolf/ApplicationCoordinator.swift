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
    var cancellableBag = Set<AnyCancellable>()
    @ObservedObject var multipeer = GameMultipeerSession()
    
    // MARK: ViewControllers
    
    let lobbyVC = LobbyViewController()
    let gameVC = GameViewController()
    
    // MARK: Initialize
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        lobbyVC.delegate = self
        gameVC.delegate = self
        window.rootViewController = UINavigationController(rootViewController: lobbyVC)
        window.makeKeyAndVisible()
        setupCard()
    }
    
    func setupCard() {
        card = multipeer.currentCard
        card.objectWillChange.sink {
            print("card changed")
        }.store(in: &cancellableBag)
        
        card.$type.sink { value in
            self.gameVC.imageView.image = value.image
        }.store(in: &cancellableBag)
    }
}

extension ApplicationCoordinator: LobbyViewControllerDelegate {
    func hostGame() {
        multipeer.host()
    }
    
    func joinGame() {
        multipeer.join()
    }
    
    func goToGame() {
        lobbyVC.navigationController?.pushViewController(gameVC, animated: true)
    }
}

extension ApplicationCoordinator: GameViewControllerDelegate {
    func sendCard() {
        multipeer.sendCard()
    }
}
