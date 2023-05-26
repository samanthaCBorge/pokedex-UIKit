//
//  UserDefaultsManager.swift
//  poke-test
//
//  Created by Samantha Cruz on 26/5/23.
//

import Foundation

enum Provider: String {
    case google
}

public enum StorageKey: String {
    case provider
}

public protocol UserDefaultsManagerProtocol: AnyObject {
    var provider: String { get set }
}

public final class UserDefaultsManager: UserDefaultsManagerProtocol {
    public static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard
    
    public var provider: String {
        get {
            defaults.string(forKey: StorageKey.provider.rawValue) ?? ""
        }
        set(value) {
            defaults.set(value, forKey: StorageKey.provider.rawValue)
        }
    }
}
