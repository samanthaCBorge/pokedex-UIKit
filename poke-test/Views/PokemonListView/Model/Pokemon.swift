//
//  Pokemon.swift
//  poke-test
//
//  Created by Samantha Cruz on 26/5/23.
//

import Foundation

struct Pokemon: Codable, Hashable {
    var name: String
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case url
    }
}

struct PokemonEntry: Codable, Hashable {
    var pokemon: Pokemon
    
    enum CodingKeys: String, CodingKey {
        case pokemon = "pokemon_species"
    }
}

extension Pokemon {
    var getParentDict: [String: Any] {
        ["name": name, "url": url]
    }
}
