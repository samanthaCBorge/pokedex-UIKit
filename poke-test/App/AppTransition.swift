//
//  AppTransition.swift
//  poke-test
//
//  Created by Samantha Cruz on 28/2/23.
//

import Foundation

enum AppTransition {
    
    case showLogin
    case showWelcome
    case showHome
    case showPokedex(model: Region)
    case showPokemons(model: Pokedex)
    
    var hasState: Bool {
        false
    }
    
    func coordinatorFor<R: AppRouter>(router: R) -> Coordinator {
        switch self {
        case .showLogin: return LogInCoordinator(router: router)
        case .showWelcome: return WelcomeCoordinator(router: router)
        case .showHome: return HomeCoordinator(router: router)
        case .showPokedex(let model): return PokedexListCoordinator(model: model, router: router)
        case .showPokemons(let model): return PokemonListCoordinator(model: model, router: router)
        }
    }
}

extension AppTransition: Hashable {
    
    var identifier: String {
        switch self {
        case .showLogin: return "showLogin"
        case .showWelcome: return "showWelcome"
        case .showHome: return "showHome"
        case .showPokedex: return "showPokedex"
        case .showPokemons: return "showPokemon"
        }
    }
    
    static func == (lhs: AppTransition, rhs: AppTransition) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
