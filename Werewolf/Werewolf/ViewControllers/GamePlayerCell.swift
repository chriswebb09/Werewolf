//
//  GamePlayerCell.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import UIKit

class GamePlayerCellViewModel {
    var player: Player
    var card: Card
    
    init(player: Player, card: Card) {
        self.player = player
        self.card = card
    }
}

class GamePlayerCell: UICollectionViewCell {
    
    static let reuseID = "GamePlayerCell"
    
    private var viewModel: GamePlayerCellViewModel!
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Werewolf")
        imageView.isHidden = true
        imageView.layer.cornerRadius = 40
        return imageView
    }()
    
    var blankImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.layer.cornerRadius = 40
        return imageView
    }()
    
    func setup(viewModel: GamePlayerCellViewModel) {
        self.viewModel = viewModel
        imageView.image = viewModel.card.type.image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(imageView)
        imageView.frame = contentView.frame
        imageView.layer.cornerRadius = 40
        
        contentView.addSubview(blankImage)
        blankImage.frame = contentView.frame
        blankImage.layer.cornerRadius = 40
        
    }
    
    func flip() {
        let flipSide: UIView.AnimationOptions = blankImage.isHidden ? .transitionFlipFromLeft : .transitionFlipFromRight
        UIView.transition(with: self.contentView, duration: 0.3, options: flipSide, animations: { [weak self]  () -> Void in
            self?.imageView.isHidden = !(self?.imageView.isHidden ?? true)
            self?.blankImage.isHidden = !(self?.blankImage.isHidden ?? false)
        }, completion: nil)
    }
}
