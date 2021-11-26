//
//  LobbyViewController.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import UIKit

class LobbyViewController: UIViewController {
    
    weak var delegate: LobbyViewControllerDelegate?
    
    var joinButton: UIButton = {
        let joinButton = UIButton(frame: CGRect(x: 30, y: 600, width: 150, height: 50))
        return joinButton
    }()
    
    var hostButton: UIButton = {
        let hostButton =  UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 180, y: 600, width: 150, height: 50))
        return hostButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    func setup() {
        view.addSubview(joinButton)
        view.addSubview(hostButton)
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
        delegate?.hostGame()
        delegate?.goToGame()
    }
    
    @objc func joinTapped(_ sender: Any) {
        delegate?.joinGame()
        delegate?.goToGame()
    }
}

