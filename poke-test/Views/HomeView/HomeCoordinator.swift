//
//  HomeCoordinator.swift
//  poke-test
//
//  Created by Samantha Cruz on 22/5/23.
//

import UIKit

final class HomeCoordinator<R: AppRouter> {
    let router: R
    
    private lazy var primaryViewController: UIViewController = {
        let viewModel = HomeViewModel<R>()
        viewModel.router = router
        let viewController = HomeViewController(viewModel: viewModel)
        return viewController
    }()
    
    init(router: R) {
        self.router = router
    }
}

extension HomeCoordinator: Coordinator {
    func start() {
        if router.navigationController.viewControllers.isEmpty {
            router.navigationController.pushViewController(primaryViewController, animated: false)
        } else {
            router.navigationController.viewControllers.removeAll()
            router.navigationController.pushViewController(primaryViewController, animated: false)
        }
    }
}
