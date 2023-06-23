//
//  PokemonInfo.swift
//  poke-test
//
//  Created by Samantha Cruz on 30/5/23.
//

import Foundation
import UIKit
import SVGKit

struct PokemonInfo: Codable, Hashable {
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

struct Stat: Codable, Hashable {
    let baseStat, effort: Int
    let stat: Species

    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case effort, stat
    }
}

struct Species: Codable, Hashable {
    let name: String
    let url: String
    
    var color: UIColor {
        switch name {
        case "fire":
            return .flatRed()
        case "poison":
            return .flatPlum()
        case "bug":
            return .flatGreen()
        case "water":
            return .flatTeal()
        case "electric":
            return .flatYellow()
        case "psychic":
            return .flatPurple()
        case "normal":
            return .flatOrange()
        case "ground":
            return .flatBrown()
        case "flying":
            return .flatSkyBlue()
        case "fairy":
            return .flatPink()
        case "grass":
            return .flatMint()
        default:
            return .flatMagenta()
        }
    }
    
    var typeIcon: String {
        switch name {
        case "fire":
            return "fire"
        case "poison":
            return "poison"
        case "bug":
            return "bug"
        case "water":
            return "water"
        case "electric":
            return "electric"
        case "psychic":
            return "psychic"
        case "normal":
            return "normal"
        case "ground":
            return "ground"
        case "flying":
            return "flying"
        case "fairy":
            return "fairy"
        case "grass":
            return "grass"
        case "ice":
            return "ice"
        case "steel":
            return "steel"
        case "rock":
            return "rock"
        default:
            return "fire"
        }
    }
}

struct TypeElement: Codable, Hashable {
    let slot: Int
    let type: Species
}


