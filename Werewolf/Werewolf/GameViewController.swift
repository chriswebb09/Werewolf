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
    
    var imageView: UIImageView = {
        let frame = CGRect(x: (UIScreen.main.bounds.width / 2) - 150, y: 100, width: 300, height: 400)
        let imageView = UIImageView(frame: frame)
        return imageView
    }()
    
    weak var delegate: GameViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    func setup() {
        view.addSubview(imageView)
        imageView.backgroundColor = .blue
        view.addSubview(sendCardButton)
        sendCardButton.tintColor = .blue
        sendCardButton.backgroundColor = .blue
        sendCardButton.setTitle("SEND CARD", for: .normal)
        sendCardButton.addTarget(self, action: #selector(sendCard(_:)), for: .touchUpInside)
    }
    
    @objc func sendCard(_ sender: Any) {
        delegate?.sendCard()
    }
}
