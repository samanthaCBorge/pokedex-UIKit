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
    func didTapItem(model: Pokemon)
    func saveTeam(title: String)
    var pokemonListSubject: PassthroughSubject<[PokemonEntry], Failure> { get }
    var selectedPokemons: [Pokemon] { get set }
    var currentMode: Mode { get set }
}

final class PokemonListViewModel<R: AppRouter> {
    var router: R?
    
    let pokemonListSubject = PassthroughSubject<[PokemonEntry], Failure>()
    private var cancellables = Set<AnyCancellable>()
    private let store: PokemonListStore
    private let pokedex: Pokedex
    private var region = ""
    var currentMode: Mode = .notTeam
    var selectedPokemons = [Pokemon]()
    
    init(pokedex: Pokedex, store: PokemonListStore = APIManager()) {
        self.store = store
        self.pokedex = pokedex
    }
}

extension PokemonListViewModel: PokemonListViewModelRepresentable {
    
    func saveTeam(title: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let id = UUID().uuidString
        let team = Team(identifier: id, title: title, region: region, pokemons: selectedPokemons)
        
        store.saveTeam(userId: userId, model: team)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func didTapItem(model: Pokemon) {
        router?.process(route: .showPokemon(model: model))
    }
    
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
