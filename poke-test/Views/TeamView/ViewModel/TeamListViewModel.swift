//
//  TeamListViewModel.swift
//  poke-test
//
//  Created by Samantha Cruz on 12/10/23.
//

import UIKit
import Combine
import Firebase

protocol TeamListViewModelRepresentable {
    func loadData()
    func didTapItem(model: Team)
    func updateTitleTeam(team: Team)
    func deleteTeam(team: Team)
    var teamListSubject: PassthroughSubject<[Team], Failure> { get }
    var errorSubject: PassthroughSubject<String, Error> { get }
}

final class TeamListViewModel<R: AppRouter> {
    var router: R?
    
    private var cancellables = Set<AnyCancellable>()
    private let store: TeamListStore
    let userId = Auth.auth().currentUser?.uid
    let teamListSubject = PassthroughSubject<[Team], Failure>()
    let errorSubject = PassthroughSubject<String, Error>()
    
    private var fetchedTeams = [Team]() {
        didSet {
            teamListSubject.send(fetchedTeams.sorted())
        }
    }
    
    init(store: TeamListStore = APIManager()) {
        self.store = store
    }
    
    private func reloadData() {
        fetchedTeams = []
        loadData()
    }
}

extension TeamListViewModel: TeamListViewModelRepresentable {

    func didTapItem(model: Team) {
        router?.process(route: .showPokemonTeam(model: model))
    }
    
    func loadData() {
        guard let mainId = userId else { return }
        
        let recieved = { (response: [String : Team]) -> Void in
            response.values.forEach { value in
                DispatchQueue.main.async { [unowned self] in
                    fetchedTeams.append(value as Team)
                }
            }
        }
        
        let completion = { [unowned self] (completion: Subscribers.Completion<Failure>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                errorSubject.send(failure.localizedDescription)
            }
        }
        
        store.readTeams(userId: mainId)
            .sink(receiveCompletion: completion, receiveValue: recieved)
            .store(in: &cancellables)
    }
    
    func updateTitleTeam(team: Team) {
        guard let mainId = userId else { return }
        
        let recieved = { [unowned self] (response: Bool) -> Void in
            if response {
                reloadData()
            } else {
                errorSubject.send("The title of this team could not be updated")
            }
        }
        
        store.updateTitleTeam(userId: mainId, team: team)
            .sink(receiveCompletion: { _ in}, receiveValue: recieved)
            .store(in: &cancellables)
    }
    
    func deleteTeam(team: Team) {
        guard let mainId = userId else { return }
        
        let recieved = { [unowned self] (response: Bool) -> Void in
            if response {
                reloadData()
            } else {
                errorSubject.send("Could not delete \(team.title)")
            }
        }
        
        store.deleteTeam(userId: mainId, team: team)
            .sink(receiveCompletion: { _ in}, receiveValue: recieved)
            .store(in: &cancellables)
    }
}

