//
//  KeychainStorage.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

import KeychainSwift
import Swiftagram

/// A `struct` holding reference to all `Secret`s stored in the keychain.
/// - note: `
///     KeychainStorage` is the encoded and ready-to-use alternative to `UserDefaultsStorage`.
public struct KeychainStorage: Storage {
    /// A `String` identifying the `KeychainSwift` prefix. Defaults to `swiftagram`. Defaults to `swiftagram`.
    public let prefix: String
    /// A `Bool` identifying whether the `Secret`s should be synchronized through iCloud. Defaults to `false`.
    public let synchronizable: Bool
    /// A `KeychainSwift` used as storage. Defaults to `.init(keyPrefix: prefix)`.
    private let keychain: KeychainSwift
    /// A `KeychainSwiftAccessOptions` value. Defaults to `.accessibleWhenUnlocked`.
    /// - note: If you need to support different access options for different `Secret`s, simply instantiate different `KeychainStorage`s.
    private let access: KeychainSwiftAccessOptions

    // MARK: Lifecycle
    /// Init.
    /// - parameters:
    ///     - prefix: A `KeychainSwift` prefix.
    ///     - access: A valid `KeychainSwiftAccessOptions` value. Defaults to `.accessibleWhenUnlocked`.
    ///     - synchronizable: A `Bool` representing whether the `Secret` should be shared through iCloud Keychain or not.
    public init(prefix: String = "swiftagram",
                access: KeychainSwiftAccessOptions = .accessibleWhenUnlocked,
                synchronizable: Bool = false) {
        self.prefix = prefix
        self.access = access
        self.synchronizable = synchronizable
        self.keychain = .init(keyPrefix: prefix)
        self.keychain.synchronizable = synchronizable
    }

    // MARK: Lookup
    /// Find a `Secret` stored in the keychain.
    /// - returns: A `Secret` or `nil` if no response could be found.
    /// - note: Use `Secret.stored` to access it.
    public func find(matching identifier: String) -> Secret? {
        return keychain
            .getData(identifier)
            .flatMap { try? JSONDecoder().decode(Secret.self, from: $0) }
    }

    /// Return all `Secret`s stored in the `keychain`.
    /// - returns: An `Array` of `Secret`s stored in the `keychain`.
    public func all() -> [Secret] {
        return keychain.allKeys
            .compactMap { $0.starts(with: prefix) ? String($0[prefix.endIndex...]) : nil }
            .compactMap(find)
    }

    // MARK: Locker
    /// Store a `Secret` in the keychain.
    /// - note: Prefer `Secret.store` to access it.
    public func store(_ response: Secret) {
        // Store.
        guard let data = try? JSONEncoder().encode(response) else { return }
        keychain.set(data, forKey: response.identifier, withAccess: access)
    }

    /// Delete a `Secret` in the keychain.
    /// - returns: The removed `Secret` or `nil` if none was found.
    @discardableResult
    public func remove(matching identifier: String) -> Secret? {
        guard let response = find(matching: identifier) else { return nil }
        keychain.delete(identifier)
        return response
    }
}
