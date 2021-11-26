//
//  CardType.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import UIKit

enum CardType: String, CaseIterable {
    case wolf, villager, seer
    
    var image: UIImage {
        switch self {
        case .wolf:
            return UIImage(named: "Werewolf")!
        case .villager:
            return UIImage(named: "Villager")!
        case .seer:
            return UIImage(named: "Seer")!
        }
    }
    
    var name: String {
        switch self {
        case .wolf:
            return "Werewolf"
        case .seer:
            return "Seer"
        case .villager:
            return "Villager"
        }
    }
}
