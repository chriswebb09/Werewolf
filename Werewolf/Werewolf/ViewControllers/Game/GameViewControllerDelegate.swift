//
//  GameViewControllerDelegate.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import Foundation
import UIKit

protocol GameViewControllerDelegate: AnyObject {
    func sendCard(id: Int)
    func presentGamePlayers(navigationController: UIViewController)
}
