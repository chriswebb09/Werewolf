//
//  Coordinator.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import UIKit

protocol Coordinator {
    var window: UIWindow { get }
    var rootController: UIViewController! { get }
    func start()
}
