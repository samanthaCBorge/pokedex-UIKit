//
//  PokemonInfoCoordinator.swift
//  poke-test
//
//  Created by Samantha Cruz on 30/5/23.
//

import UIKit

final class PokemonInfoCoordinator<R: AppRouter> {
    let router: R
    var model: Pokemon
    
    private lazy var primaryViewController: UIViewController = {
        let viewModel = PokemonInfoViewModel<R>(pokemon: model)
        viewModel.router = router
        let viewController = PokemonInfoViewController(viewModel: viewModel)
        return viewController
    }()
    
    init(model: Pokemon, router: R) {
        self.router = router
        self.model = model
    }
}

extension PokemonInfoCoordinator: Coordinator {
    func start() {
        router.navigationController.pushViewController(primaryViewController, animated: true)
    }
}

