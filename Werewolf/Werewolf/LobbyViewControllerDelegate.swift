//
//  LobbyViewControllerDelegate.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import Foundation

protocol LobbyViewControllerDelegate: AnyObject {
    func goToGame()
    func hostGame()
    func joinGame()
}
