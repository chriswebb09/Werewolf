//
//  GamePlayerCell.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import UIKit

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
        imageView.layer.masksToBounds = true
        contentView.addSubview(blankImage)
        blankImage.frame = contentView.frame
        blankImage.layer.cornerRadius = 40
        
    }
    
    func setAction(kill: Bool) {
        if kill {
            self.setToDead()
        } else {
            self.flip()
        }
    }
    
    private func flip() {
        let flipSide: UIView.AnimationOptions = blankImage.isHidden ? .transitionFlipFromLeft : .transitionFlipFromRight
        UIView.transition(with: self.contentView, duration: 0.3, options: flipSide, animations: { [weak self]  () -> Void in
            self?.imageView.isHidden = !(self?.imageView.isHidden ?? true)
            self?.blankImage.isHidden = !(self?.blankImage.isHidden ?? false)
        }, completion: nil)
    }
    
    private func setToDead() {
        blankImage.image = UIImage(systemName: "xmark")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.blankImage.image = nil
    }
}
