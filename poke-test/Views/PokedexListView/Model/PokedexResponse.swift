//
//  PokedexResponse.swift
//  poke-test
//
//  Created by Samantha Cruz on 25/5/23.
//

import Foundation

struct PokedexResponse: Codable {
    let id: Int
    let name: String
    let pokedexes: [Pokedex]
}
