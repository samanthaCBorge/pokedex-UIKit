//
//  AppTransition.swift
//  poke-test
//
//  Created by Samantha Cruz on 28/2/23.
//

import Foundation

enum AppTransition {
    
//    case showWelcome
    case showHome
    
    var hasState: Bool {
        false
    }
    
    func coordinatorFor<R: AppRouter>(router: R) -> Coordinator {
        switch self {
//        case .showWelcome: return WelcomeCoordinator(router: router)
        case .showHome: return HomeCoordinator(router: router)
        }
    }
}

extension AppTransition: Hashable {
    
    var identifier: String {
        switch self {
//        case .showWelcome: return "showWelcome"
        case .showHome: return "showHome"
        }
    }
    
    static func == (lhs: AppTransition, rhs: AppTransition) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
