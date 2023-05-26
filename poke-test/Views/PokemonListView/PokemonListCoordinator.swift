//
//  PokemonListCoordinator.swift
//  poke-test
//
//  Created by Samantha Cruz on 26/5/23.
//

import UIKit

final class PokemonListCoordinator<R: AppRouter> {
    let router: R
    var model: Pokedex
    
    private lazy var primaryViewController: UIViewController = {
        let viewModel = PokemonListViewModel<R>(pokedex: model)
        viewModel.router = router
        let viewController = PokemonListViewController(viewModel: viewModel)
        return viewController
    }()
    
    init(model: Pokedex, router: R) {
        self.router = router
        self.model = model
    }
}

extension PokemonListCoordinator: Coordinator {
    func start() {
        router.navigationController.pushViewController(primaryViewController, animated: true)
    }
}
