//
//  PokemonViewCell.swift
//  poke-test
//
//  Created by Samantha Cruz on 29/5/23.
//

import UIKit

final class PokemonViewCell: UICollectionViewCell, NibLoadable {

    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var checkMark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkMark.image = UIImage(systemName: "circle")
    }
    
    func configure(_ pokemon: Pokemon) {
        nameLabel.text = pokemon.name
        nameLabel.font = UIFont(name: "PokemonGB", size: 18) ?? UIFont.systemFont(ofSize: 18)
    }
    
    func performSelected(_ isSelected: Bool, for mode: Mode) {
        switch mode {
        case .addingTeam:
            DispatchQueue.main.async { [unowned self] in
                checkMark.image = UIImage(systemName: isSelected ? "checkmark.circle" : "circle")
                checkMark.isHidden = false
            }
        case .notTeam:
            DispatchQueue.main.async { [unowned self] in
                checkMark.isHidden = true
            }
        }
    }
}
