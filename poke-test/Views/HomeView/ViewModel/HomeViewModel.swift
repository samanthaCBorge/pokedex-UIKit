//
//  HomeViewModel.swift
//  poke-test
//
//  Created by Samantha Cruz on 22/5/23.
//

import UIKit
import Combine

protocol HomeViewModelRepresentable {
    var regionListSubject: PassthroughSubject<[Region], Failure> { get }
    func loadData()
    func goToPokedex(model: Region)
    func sendTo(_ type: MenuOption)
    func exit()
}

final class HomeViewModel<R: AppRouter> {
    var router: R?
    
    let regionListSubject = PassthroughSubject<[Region], Failure>()
    private var cancellables = Set<AnyCancellable>()
    private let store: HomeListStore
    
    init(store: HomeListStore = APIManager()) {
        self.store = store
    }
}

extension HomeViewModel: HomeViewModelRepresentable {
    
    func exit() {
        router?.exit()
    }
    
    func goToPokedex(model: Region) {
        router?.process(route: .showPokedex(model: model))
    }
    
    func loadData() {
        let recieved = { (response: RegionResponse) -> Void in
            DispatchQueue.main.async { [unowned self] in
                regionListSubject.send( response.results)
            }
        }
        
        let completion = { [unowned self] (completion: Subscribers.Completion<Failure>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                regionListSubject.send(completion: .failure(failure))
            }
        }
        
        store.readRegionList()
            .sink(receiveCompletion: completion, receiveValue: recieved)
            .store(in: &cancellables)
    }
    
    func sendTo(_ type: MenuOption) {
        switch type {
        case .teams:
            router?.process(route: .showTeamList)
        case .logOut:
            router?.exit()
        default:
            break
        }
    }
}
