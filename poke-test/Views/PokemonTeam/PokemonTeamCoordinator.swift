//
//  PokemonTeamCoordinator.swift
//  poke-test
//
//  Created by Samantha Cruz on 12/10/23.
//

import UIKit

final class PokemonTeamCoordinator<R: AppRouter> {
    let router: R
    var model: Team
    
    private lazy var primaryViewController: UIViewController = {
        let viewModel = PokemonTeamViewModel<R>(team: model)
        viewModel.router = router
        let viewController = PokemonTeamViewController(viewModel: viewModel)
        return viewController
    }()
    
    init(model: Team, router: R) {
        self.router = router
        self.model = model
    }
}

extension PokemonTeamCoordinator: Coordinator {
    func start() {
        router.navigationController.pushViewController(primaryViewController, animated: true)
    }
}

