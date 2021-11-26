//
//  Deck.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import Foundation

struct Deck {
    private var cards: [Card] = []
    
    init() {
        for card in CardType.types {
            cards.append(Card.createCard(type: card))
        }
    }
    
    mutating func shuffleDeck() {
        cards.shuffle()
    }
    
    mutating func deal() -> Card {
        return cards.removeFirst()
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }

        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            self.swapAt(i, j)
        }
    }
}

extension Collection {
    /// Return a copy of `self` with its elements shuffled.
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}
