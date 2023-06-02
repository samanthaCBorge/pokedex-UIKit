//
//  App.swift
//  poke-test
//
//  Created by Samantha Cruz on 28/2/23.
//

import GoogleSignIn
import UIKit

final class App {
    var navigationController = UINavigationController()
    private var coordinatorRegister: [AppTransition: Coordinator] = [:]
}

extension App: Coordinator {
    func start() {
        var isSession: Bool {
            !UserDefaultsManager.shared.provider.isEmpty
        }
        process(route:  .showHome)
    }
} 

extension App: AppRouter {
    
    func exit() {
        if UserDefaultsManager.shared.provider == Provider.google.rawValue {
            GIDSignIn.sharedInstance.signOut()
        }

        UserDefaultsManager.shared.provider = ""
        navigationController.popToRootViewController(animated: true)
        process(route: .showLogin)
    }
    
    func process(route: AppTransition) {
        print("Processing route: \(route)")
        let coordinator = route.hasState ? coordinatorRegister[route] : route.coordinatorFor(router: self)
        coordinator?.start()
    }
}

