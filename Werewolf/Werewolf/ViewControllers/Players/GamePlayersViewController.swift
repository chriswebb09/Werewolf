//
//  GamePlayersViewController.swift
//  Werewolf
//
//  Created by Christopher Webb on 11/25/21.
//

import UIKit

class GamePlayersViewController: UIViewController {
    
    var collectionView: UICollectionView!
    weak var delegate: GamePlayersViewControllerDelegate?
    var isWerewolf: Bool = false
    var numberOfPlayersCanKill = 1
    
    let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return layout
    }()
    
    var gamePlayers: [Player] = []
    var presenting: Bool = false
    
    let compositionalLayout: UICollectionViewCompositionalLayout = {
        let fraction: CGFloat = 1 / 3
        let inset: CGFloat = 2.5
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.45))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: compositionalLayout)
        view.addSubview(collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.frame = view.frame
        collectionView.register(GamePlayerCell.self, forCellWithReuseIdentifier: GamePlayerCell.reuseID)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    override func endAppearanceTransition() {
        if isBeingDismissed{
            presenting = false
            print("dismissal logic here")
        }
    }
}

extension GamePlayersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gamePlayers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GamePlayerCell.reuseID, for: indexPath) as! GamePlayerCell
        let player = gamePlayers[indexPath.row]
        cell.imageView.image = player.card?.type.image
        if !player.playerInGame {
            cell.setAction(kill: true)
            print("\n\n\(indexPath.row)")
            print(player.name)
            return cell
        }
        return cell
    }
}

extension GamePlayersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let numberOfItemsPerRow: CGFloat = 3
        let spacing: CGFloat = flowLayout.minimumInteritemSpacing
        let availableWidth = width - spacing * (numberOfItemsPerRow + 1)
        let itemDimension = floor(availableWidth / numberOfItemsPerRow)
        return CGSize(width: itemDimension, height: itemDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let player = gamePlayers[indexPath.row]
        guard let cell = collectionView.cellForItem(at: indexPath) as? GamePlayerCell else {
            return
        }
        
        if isWerewolf {
            if self.numberOfPlayersCanKill > 0 {
                cell.setAction(kill: true)
                player.playerInGame = false
                gamePlayers[indexPath.row] = player
                delegate?.kill(player: player)
                self.numberOfPlayersCanKill -= 1
                self.collectionView.reloadData()
            }
            
            if self.numberOfPlayersCanKill == 0 {
                self.dismiss(animated: true, completion: nil)
            }
            
        } else {
            cell.setAction(kill: false)
        }
    }
}
