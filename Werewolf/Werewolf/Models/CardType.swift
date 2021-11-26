//
//  CardType.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import UIKit

enum CardType: String, CaseIterable {
    case wolf, villager, seer, tanner, minion, hunter, cursed, cupid, bodyguard, blank
    
    var image: UIImage {
        switch self {
        case .wolf:
            return UIImage(named: "Werewolf")!
        case .villager:
            return UIImage(named: "Villager")!
        case .seer:
            return UIImage(named: "Seer")!
        case .tanner:
            return UIImage(named: "Tanner")!
        case .minion:
            return UIImage(named: "Minion")!
        case .hunter:
            return UIImage(named: "Hunter")!
        case .cursed:
            return UIImage(named: "Cursed")!
        case .cupid:
            return UIImage(named: "Cupid")!
        case .bodyguard:
            return UIImage(named: "Bodyguard")!
        case .blank:
            return UIImage(systemName: "photo")!
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
        case .tanner:
            return "Tanner"
        case .minion:
            return "Minion"
        case .hunter:
            return "Hunter"
        case .cursed:
            return "Cursed"
        case .cupid:
            return "Cupid"
        case .bodyguard:
            return "Bodyguard"
        case .blank:
            return "Blank"
        }
    }
    
    static var types: [CardType] {
        return CardType.allCases
    }
}
