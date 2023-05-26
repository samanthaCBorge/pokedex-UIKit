//
//  LogInCoordinator.swift
//  poke-test
//
//  Created by Samantha Cruz on 26/5/23.
//

import UIKit

final class LogInCoordinator<R: AppRouter> {
    let router: R
    
    private lazy var primaryViewController: UIViewController = {
        let viewModel = LogInViewModel<R>()
        viewModel.router = router
        let viewController = LogInViewController(viewModel: viewModel)
        return viewController
    }()
    
    init(router: R) {
        self.router = router
    }
}

extension LogInCoordinator: Coordinator {
    func start() {
        router.navigationController.pushViewController(primaryViewController, animated: true)
    }
}
