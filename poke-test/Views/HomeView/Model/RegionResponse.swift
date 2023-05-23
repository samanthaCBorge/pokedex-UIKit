//
//  RegionResponse.swift
//  poke-test
//
//  Created by Samantha Cruz on 22/5/23.
//

import Foundation

struct RegionResponse: Codable {
    let count: Int
    let results: [Region]
}
