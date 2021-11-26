//
//  GamePlayersViewControllerDelegate.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/26/21.
//

import Foundation

protocol GamePlayersViewControllerDelegate: AnyObject {
    func kill(player: Player)
}
