//
//  GameViewController.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import UIKit

class GameViewController: UIViewController {
    
    var sendCardButton: UIButton = {
        let frame = CGRect(x: (UIScreen.main.bounds.width / 2) - 75, y: 700, width: 150, height: 50)
        let button = UIButton(frame: frame)
        return button
    }()
    
    var showPlayersButton: UIButton = {
        let frame = CGRect(x: (UIScreen.main.bounds.width / 2) - 75, y: 500, width: 150, height: 50)
        let button = UIButton(frame: frame)
        return button
    }()
    
    var imageView: UIImageView = {
        let frame = CGRect(x: (UIScreen.main.bounds.width / 2) - 150, y: 100, width: 300, height: 400)
        let imageView = UIImageView(frame: frame)
        return imageView
    }()
    
    var playersJoined: Bool = false
    weak var delegate: GameViewControllerDelegate?
    var isHost: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setup() {
        if !isHost {
            view.addSubview(imageView)
        } else {
            imageView.backgroundColor = .lightGray
            view.addSubview(sendCardButton)
            sendCardButton.tintColor = .blue
            sendCardButton.backgroundColor = .blue
            sendCardButton.setTitle("SEND CARD", for: .normal)
            sendCardButton.addTarget(self, action: #selector(sendCard(_:)), for: .touchUpInside)
            
            view.addSubview(showPlayersButton)
            showPlayersButton.tintColor = .blue
            showPlayersButton.backgroundColor = .blue
            showPlayersButton.setTitle("SHOW PLAYERS", for: .normal)
            showPlayersButton.addTarget(self, action: #selector(showPlayers(_:)), for: .touchUpInside)
        }
    }
    
    @objc func sendCard(_ sender: Any) {
        let index = Int.random(in: 0...1)
        delegate?.sendCard(id: index)
    }
    
    @objc func showPlayers(_ sender: Any) {
        delegate?.presentGamePlayers(navigationController: navigationController!)
    }
}
