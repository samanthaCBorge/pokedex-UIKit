//
//  Team.swift
//  poke-test
//
//  Created by Samantha Cruz on 12/10/23.
//

import Foundation

struct Team: Codable, Identifiable {
    let id = UUID().uuidString
    var identifier: String
    var title: String
    var region: String
    var pokemons: [Pokemon]
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case title
        case region
        case pokemons
    }
}

extension Team: Hashable {
    static func == (lhs: Team, rhs: Team) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

extension Team: Comparable {
    static func <(lhs: Team, rhs: Team) -> Bool {
        lhs.title < rhs.title
    }
}
