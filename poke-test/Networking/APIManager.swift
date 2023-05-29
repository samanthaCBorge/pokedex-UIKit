//
//  APIManager.swift
//  poke-test
//
//  Created by Samantha Cruz on 22/5/23.
//

import UIKit
import Combine
import CodableFirebase
import Firebase

protocol HomeListStore {
    func readRegionList() -> Future<RegionResponse, Failure>
}

protocol PokedexListStore {
    func readPokedex(region: Region) -> Future<PokedexResponse, Failure>
}

protocol PokemonListStore {
    func readPokemons(pokedex: Pokedex) -> Future<PokemonResponse, Failure>
    func saveTeam(userId: String, model: Team) -> Future<Bool, Failure>
}

protocol PokemonDetailStore {
//    func readPokemonDetails(pokemon: Pokemon) -> Future<PokemonDetailBase, Failure>
}

final class APIManager {
    private var database: DatabaseReference {
        Database.database().reference()
    }
    
    private func request<T>(for stringURL: String) -> Future<T, Failure> where T : Codable {
        return Future { promise in
            
            guard let url = URL(string: stringURL) else {
                promise(.failure(.urlConstructError))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard let data = data, case .none = error else { promise(.failure(.urlConstructError)); return }
                do {
                    let decoder = JSONDecoder()
                    let searchResponse = try decoder.decode(T.self, from: data)
                    promise(.success(searchResponse))
                } catch {
                    promise(.failure(.APIError(error)))
                }
            }
            task.resume()
        }
    }
    
    static func fetchImage(imageURL: String) async throws -> UIImage {
        guard let url = URL(string: imageURL) else { throw Failure.urlConstructError }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  let image = UIImage(data: data), 200...299 ~= statusCode else { throw Failure.statusCode }
            return image
        } catch {
            throw error
        }
    }
}

extension APIManager: HomeListStore {
    func readRegionList() -> Future<RegionResponse, Failure> {
        let url = "https://pokeapi.co/api/v2/region"
        return request(for: url)
    }
}

extension APIManager: PokedexListStore {
    func readPokedex(region: Region) -> Future<PokedexResponse, Failure> {
        return request(for: region.url)
    }
    
    func saveTeam(userId: String, model: Team) -> Future<Bool, Failure> {
        return Future { [unowned self] promise in
            do {
                let data = try FirebaseEncoder().encode(model)
                database.child(userId).child("teams").child(model.identifier).setValue(data)
                promise(.success(true))
            } catch {
                promise(.failure(.APIError(error)))
            }
        }
    }
    
}

extension APIManager: PokemonListStore {
    func readPokemons(pokedex: Pokedex) -> Future<PokemonResponse, Failure> {
        return request(for: pokedex.url)
    }
}


extension APIManager: PokemonDetailStore {
//    func readPokemonDetails(pokemon: Pokemon) -> Future<PokemonDetailBase, Failure> {
//        return request(for: pokemon.url)
//    }
}

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
