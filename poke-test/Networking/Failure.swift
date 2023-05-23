//
//  Failure.swift
//  poke-test
//
//  Created by Samantha Cruz on 22/5/23.
//

import Foundation

enum Failure: Error {
    case decodingError
    case urlConstructError
    case APIError(Error)
    case statusCode
}

