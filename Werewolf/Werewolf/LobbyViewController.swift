//
//  LobbyViewController.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import UIKit
import Combine
import MultipeerConnectivity
import SwiftUI

protocol LobbyViewControllerDelegate: AnyObject {
    func goToGame()
    func hostGame()
    func joinGame()
}

class LobbyViewController: UIViewController {
    
    weak var delegate: LobbyViewControllerDelegate?
    
    var joinButton: UIButton = UIButton(frame: CGRect(x: 30, y: 600, width: 150, height: 50))
    var hostButton: UIButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 180, y: 600, width: 150, height: 50))
    
    @ObservedObject var multipeer = GameMultipeerSession()
   
    var card: Card!
    
    var cancellableBag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(joinButton)
        self.view.addSubview(hostButton)
        joinButton.tintColor = .blue
        hostButton.tintColor = .blue
        hostButton.backgroundColor = .blue
        joinButton.backgroundColor = .blue
        joinButton.setTitle("JOIN GAME", for: .normal)
        hostButton.setTitle("HOST GAME", for: .normal)
        hostButton.addTarget(self, action: #selector(hostTapped(_:)), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(joinTapped(_:)), for: .touchUpInside)
    }
    
    @objc func hostTapped(_ sender: Any) {
      //  multipeer.host()
        delegate?.hostGame()
        delegate?.goToGame()
    }
    
    @objc func joinTapped(_ sender: Any) {
       // multipeer.join()
        delegate?.joinGame()
        delegate?.goToGame()
    }
}

