//
//  PokedexViewModel.swift
//  poke-test
//
//  Created by Samantha Cruz on 25/5/23.
//

import UIKit
import Combine

protocol PokedexListViewModelRepresentable {
    func loadData()
    func didTapItem(model: Pokedex)
    var pokedexListSubject: PassthroughSubject<[Pokedex], Failure> { get }
}

final class PokedexListViewModel<R: AppRouter> {
    var router: R?
    
    let pokedexListSubject = PassthroughSubject<[Pokedex], Failure>()
    private var cancellables = Set<AnyCancellable>()
    private let store: PokedexListStore
    private let region: Region
    
    init(region: Region, store: PokedexListStore = APIManager()) {
        self.store = store
        self.region = region
    }
}

extension PokedexListViewModel: PokedexListViewModelRepresentable {
    func didTapItem(model: Pokedex) {
        router?.process(route: .showPokemons(model: model))
    }
    
    func loadData() {
        let recieved = { (response: PokedexResponse) -> Void in
            DispatchQueue.main.async { [unowned self] in
                pokedexListSubject.send( response.pokedexes)
            }
        }
        
        let completion = { [unowned self] (completion: Subscribers.Completion<Failure>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                pokedexListSubject.send(completion: .failure(failure))
            }
        }
        
        store.readPokedex(region: region)
            .sink(receiveCompletion: completion, receiveValue: recieved)
            .store(in: &cancellables)
    }
}
