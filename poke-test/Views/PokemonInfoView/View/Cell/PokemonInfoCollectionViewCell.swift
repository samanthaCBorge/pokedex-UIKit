//
//  PokemonInfoCollectionViewCell.swift
//  poke-test
//
//  Created by Samantha Cruz on 9/6/23.
//

import UIKit

final class PokemonInfoCollectionViewCell: UICollectionViewCell, NibLoadable {

    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configCell(_ pokemon: TypeElement) {
        nameLabel.text = pokemon.type.name.uppercased()
        imageView.image = UIImage(named: pokemon.type.typeIcon)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 0.5*imageView.frame.width
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
    }
}
