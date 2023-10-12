//
//  PokemonTeamViewModel.swift
//  poke-test
//
//  Created by Samantha Cruz on 12/10/23.
//

import UIKit

protocol PokemonTeamViewModelRepresentable {
    var team: Team { get }
    func didTapItem(model: Pokemon)
}

final class PokemonTeamViewModel<R: AppRouter> {
    var router: R?
    let team: Team
    
    init(team: Team) {
        self.team = team
    }
}

extension PokemonTeamViewModel: PokemonTeamViewModelRepresentable {
    func didTapItem(model: Pokemon) {
//        router?.process(route: .showP(model: model))
    }
}

