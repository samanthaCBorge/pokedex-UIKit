//
//  PokemonInfoCollectionViewCell.swift
//  poke-test
//
//  Created by Samantha Cruz on 9/6/23.
//

import UIKit

final class PokemonInfoCollectionViewCell: UICollectionViewCell, NibLoadable {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configCell(_ pokemon: TypeElement) {
        nameLabel.text = pokemon.type.name
        nameLabel.textColor = .white
    }
}

