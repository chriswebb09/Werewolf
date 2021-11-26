//
//  Game.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import Foundation

enum GameState {
    case night
    case day
}

enum GameSubstate {
    case pickingCard
    case waitingForOthers
    case pickingWinner
}
