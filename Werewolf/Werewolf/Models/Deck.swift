//
//  Deck.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import Foundation

class Deck {
    var cards: [Card] = []
    
    init() {
        for card in CardType.types {
            cards.append(Card.createCard(type: card))
        }
    }
}
