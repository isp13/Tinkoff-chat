//
//  AvatarItemCollectionViewCell.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 21.04.2021.
//

import UIKit

class AvatarItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private var imageView: UIImageView!
    
    func configure(with model: AvatarViewModel) {
       imageView.image = model.image ?? UIImage(named: "AppIcon")
        contentView.backgroundColor = .clear
    }
}
