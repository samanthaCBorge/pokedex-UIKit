//
//  PokemonInfoViewController.swift
//  poke-test
//
//  Created by Samantha Cruz on 30/5/23.
//

import UIKit
import Combine

final class PokemonInfoViewController: UIViewController {
    
    @IBOutlet private var stackView: UIStackView!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var nameLabel: UILabel!
    
    @IBOutlet private var typeLabel: UILabel!
    
    @IBOutlet private var height: UILabel!
    
    @IBOutlet private var weight: UILabel!
    
    
    @IBOutlet weak var backgroundView: UIView!
    
    private var subscription: AnyCancellable?
    private let viewModel: PokemonInfoViewModelRepresentable
    
    init(viewModel: PokemonInfoViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindUI()
    }
    
    private func setUI() {
        viewModel.loadData()
        nameLabel.font = UIFont(name: "Pokemon Solid", size: 28) ?? UIFont.systemFont(ofSize: 18)
        typeLabel.layer.borderWidth = 1.0
        typeLabel.layer.cornerRadius = 12
        typeLabel.backgroundColor = UIColor.gray
        typeLabel.layer.masksToBounds = true
        
    }
    
    private func bindUI() {
        subscription = viewModel.pokemonInfoSubject.sink { [unowned self] completion in
            switch completion {
            case .finished:
                print("Received completion in VC", completion)
            case .failure(let error):
                presentAlert(with: error)
            }
        } receiveValue: { [unowned self] pokemonInfo in
            setPokemonInfo(pokemonInfo)
        }
    }
    
    private func setPokemonInfo(_ pokemon: PokemonInfo?) {
        guard let pokemon = pokemon else { return }
        nameLabel.text = pokemon.name
        typeLabel.text = pokemon.types.first?.type.name
        height.text = "\(pokemon.height)"
        weight.text = "\(pokemon.weight)"
    
        
        var backgroundColor: UIColor {
            switch pokemon.types.first?.type.name {
            case "fire": return .systemRed
            case "poison", "bug": return .systemGreen
            case "water": return .systemTeal
            case "electric": return .systemYellow
            case "psychic": return .systemPurple
            case "normal": return .systemOrange
            case "ground": return .systemGray
            case "flying": return .systemBlue
            case "fairy": return .systemPink
            default: return .systemIndigo
            }
        }
        
        backgroundView.backgroundColor = backgroundColor

        pokemon.stats.forEach { item in
            let view = StatsView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 20).isActive = true
            view.config(pokemon: item)

            DispatchQueue.main.async { [unowned self] in
                stackView.addArrangedSubview(view)
            }
        }

        Task {
            let imageURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemon.id).png"
            imageView.image = await ImageCacheStore.shared.getCacheImage(for: imageURL)
        }
    }
}





