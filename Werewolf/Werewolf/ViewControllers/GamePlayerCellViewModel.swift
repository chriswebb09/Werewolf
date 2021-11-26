//
//  GamePlayerCellViewModel.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/26/21.
//

import Foundation

class GamePlayerCellViewModel {
    var player: Player
    var card: Card
    
    init(player: Player, card: Card) {
        self.player = player
        self.card = card
    }
}
