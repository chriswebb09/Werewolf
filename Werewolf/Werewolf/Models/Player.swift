//
//  Player.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import Foundation

class Player {
    var name: String
    var deviceID: String
    var card: Card?
    
    init(name: String, deviceID: String) {
        self.name = name
        self.deviceID = deviceID
    }
    
    func setRandomCard() {
        let index = Int.random(in: 0...3)
        let type = CardType.types[index]
        let card = Card(name: type.name, type: type)
        self.card = card
    }
}


// MARK: - Hashable

extension Player: Hashable {
    
    var hashValue: Int {
        return (self.name + self.deviceID).hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.deviceID)
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.name == rhs.name && rhs.deviceID == lhs.deviceID
    }
}

