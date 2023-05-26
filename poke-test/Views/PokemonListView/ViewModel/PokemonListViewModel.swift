//
//  PokemonListViewModel.swift
//  poke-test
//
//  Created by Samantha Cruz on 26/5/23.
//

import Combine
import Firebase
import UIKit

protocol PokemonListViewModelRepresentable {
    func loadData()
//    func didTapItem(model: Pokemon)
    var pokemonListSubject: PassthroughSubject<[PokemonEntry], Failure> { get }
//    var selectedPokemons: [Pokemon] { get set }
}

final class PokemonListViewModel<R: AppRouter> {
    var router: R?
    
    let pokemonListSubject = PassthroughSubject<[PokemonEntry], Failure>()
    private var cancellables = Set<AnyCancellable>()
    private let store: PokemonListStore
    private let pokedex: Pokedex
    private var region = ""
    var selectedPokemons = [Pokemon]()
    
    init(pokedex: Pokedex, store: PokemonListStore = APIManager()) {
        self.store = store
        self.pokedex = pokedex
    }
}

extension PokemonListViewModel: PokemonListViewModelRepresentable {
    
//    func didTapItem(model: Pokemon) {
////        router?.process(route: .showPokemonDetail(model: model))
//    }
    
    func loadData() {
        let recieved = { (response: PokemonResponse) -> Void in
            DispatchQueue.main.async { [unowned self] in
                region = response.region.name
                pokemonListSubject.send(response.pokemonEntry)
            }
        }
        
        let completion = { [unowned self] (completion: Subscribers.Completion<Failure>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                pokemonListSubject.send(completion: .failure(failure))
            }
        }
        
        store.readPokemons(pokedex: pokedex)
            .sink(receiveCompletion: completion, receiveValue: recieved)
            .store(in: &cancellables)
    }
}
