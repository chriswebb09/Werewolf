//
//  Card.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import Combine

class Card: ObservableObject {
    @Published var name: String
    @Published var type: CardType
    
    init(name: String, type: CardType) {
        self.name = name
        self.type = type
    }
}
