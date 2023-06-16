//
//  PokemonInfoViewModel.swift
//  poke-test
//
//  Created by Samantha Cruz on 30/5/23.
//

import UIKit
import Combine

protocol PokemonInfoViewModelRepresentable {
    var pokemonInfoSubject: CurrentValueSubject<PokemonInfo?, Failure> { get }
    func colorBackground(_ pokemon: String) -> UIColor
    var types: TypeElement? { get }
    func loadData()
}

final class PokemonInfoViewModel<R: AppRouter> {
    var router: R?
    
    let pokemonInfoSubject = CurrentValueSubject<PokemonInfo?, Failure>(nil)
    private var cancellables = Set<AnyCancellable>()
    private let store: PokemonInfoStore
    private let pokemon: Pokemon
    @Published var types: TypeElement?
    
    init(pokemon: Pokemon, store: PokemonInfoStore = APIManager()) {
        self.store = store
        self.pokemon = pokemon
    }
}

extension PokemonInfoViewModel: PokemonInfoViewModelRepresentable {
    
    func colorBackground(_ pokemon: String) -> UIColor {
        var backgroundColor: UIColor {
            switch pokemon {
            case "fire":
                return .red
            case "poison", "bug":
                return .systemGreen
            case "water":
                return .systemTeal
            case "electric":
                return .systemYellow
            case "psychic":
                return .systemPurple
            case "normal":
                return .systemOrange
            case "ground":
                return .systemGray
            case "flying":
                return .systemBlue
            case "fairy":
                return .systemPink
            default:
                return .systemIndigo
            }
        }
        return backgroundColor
    }
    
    func loadData() {
        let recieved = { (response: PokemonInfo) -> Void in
            DispatchQueue.main.async { [unowned self] in
                pokemonInfoSubject.send(response)
            }
        }
        
        let completion = { [unowned self] (completion: Subscribers.Completion<Failure>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                pokemonInfoSubject.send(completion: .failure(failure))
            }
        }
        
        store.readPokemonInfo(pokemon: pokemon)
            .sink(receiveCompletion: completion, receiveValue: recieved)
            .store(in: &cancellables)
    }
}

