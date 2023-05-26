//
//  WelcomeCoordinator.swift
//  poke-test
//
//  Created by Samantha Cruz on 25/5/23.
//

import UIKit

final class WelcomeCoordinator<R: AppRouter> {
    let router: R
    
    private lazy var primaryViewController: UIViewController = {
        let viewModel = WelcomeViewModel<R>()
        viewModel.router = router
        let viewController = WelcomeViewController(viewModel: viewModel)
        return viewController
    }()
    
    init(router: R) {
        self.router = router
    }
}

extension WelcomeCoordinator: Coordinator {
    func start() {
        router.navigationController.pushViewController(primaryViewController, animated: true)
    }
}

