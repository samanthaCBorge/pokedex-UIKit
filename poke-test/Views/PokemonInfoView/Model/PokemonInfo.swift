//
//  PokemonInfo.swift
//  poke-test
//
//  Created by Samantha Cruz on 30/5/23.
//

import Foundation

struct PokemonInfo: Codable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let stats: [Stat]
    let types: [TypeElement]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case height
        case weight
        case stats
        case types
    }
}

struct Stat: Codable {
    let baseStat, effort: Int
    let stat: Species

    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case effort, stat
    }
}

struct Species: Codable {
    let name: String
    let url: String
}

struct TypeElement: Codable {
    let slot: Int
    let type: Species
}


