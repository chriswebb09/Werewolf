//
//  ViewController.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import UIKit
import Combine
import MultipeerConnectivity

import SwiftUI

class ViewController: UIViewController {
    
    var joinButton: UIButton = UIButton(frame: CGRect(x: 30, y: 600, width: 150, height: 50))
    var hostButton: UIButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 180, y: 600, width: 150, height: 50))
    var sendCardButton: UIButton = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width / 2) - 75, y: 700, width: 150, height: 50))
    var imageView = UIImageView(frame: CGRect(x: (UIScreen.main.bounds.width / 2) - 150, y: 100, width: 300, height: 400))
    
    @ObservedObject var multipeer = GameMultipeerSession()
   
    var card: Card!
    
    var cancellableBag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(imageView)
        imageView.backgroundColor = .blue
        self.view.addSubview(joinButton)
        self.view.addSubview(hostButton)
        self.view.addSubview(sendCardButton)
        joinButton.tintColor = .blue
        hostButton.tintColor = .blue
        sendCardButton.tintColor = .blue
        hostButton.backgroundColor = .blue
        joinButton.backgroundColor = .blue
        sendCardButton.backgroundColor = .blue
        joinButton.setTitle("JOIN GAME", for: .normal)
        hostButton.setTitle("HOST GAME", for: .normal)
        sendCardButton.setTitle("SEND CARD", for: .normal)
        hostButton.addTarget(self, action: #selector(hostTapped(_:)), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(joinTapped(_:)), for: .touchUpInside)
        sendCardButton.addTarget(self, action: #selector(sendCard(_:)), for: .touchUpInside)
        card = multipeer.currentCard

        
        card.objectWillChange.sink {
            print("card changed")
        }.store(in: &cancellableBag)
        
        card.$type.sink { value in
            print("here 2")
            guard let cardType = value as? CardType  else {
                return
            }
            self.imageView.image = cardType.image
        }.store(in: &cancellableBag)
    }
    
    @objc func hostTapped(_ sender: Any) {
        multipeer.host()
    }
    
    @objc func joinTapped(_ sender: Any) {
        multipeer.join()
    }
    
    @objc func sendCard(_ sender: Any) {
        multipeer.sendCard()
    }
}

