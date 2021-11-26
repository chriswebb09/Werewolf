//
//  GameViewController.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import UIKit
import Combine
import MultipeerConnectivity
import SwiftUI


protocol GameViewControllerDelegate: AnyObject {
    func sendCard()
}
class GameViewController: UIViewController {
    
    var sendCardButton: UIButton = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width / 2) - 75, y: 700, width: 150, height: 50))
    var imageView = UIImageView(frame: CGRect(x: (UIScreen.main.bounds.width / 2) - 150, y: 100, width: 300, height: 400))
    
    weak var delegate: GameViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(imageView)
        imageView.backgroundColor = .blue
        self.view.addSubview(sendCardButton)
        sendCardButton.tintColor = .blue
        sendCardButton.backgroundColor = .blue
        sendCardButton.setTitle("SEND CARD", for: .normal)
        sendCardButton.addTarget(self, action: #selector(sendCard(_:)), for: .touchUpInside)
    }
    
    @objc func sendCard(_ sender: Any) {
        delegate?.sendCard()
    }
}
