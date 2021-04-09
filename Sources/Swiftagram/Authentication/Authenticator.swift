//
//  Authenticator.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 09/04/21.
//

import Foundation

/// A `struct` defining an instance capable of
/// starting the authentication flow for a given user.
public struct Authenticator<Storage: ComposableStorage.Storage> where Storage.Item == Secret {
    /// The underlying storage.
    public let storage: Storage
    /// The underlying client.
    public let client: Client

    /// Init.
    ///
    /// - parameters:
    ///     - storage: A valid `Storage`.
    ///     - client: A valid `Client`. Defaults to `.default`.
    public init(storage: Storage, client: Client) {
        self.storage = storage
        self.client = client
    }
}

public extension Authenticator {
    /// An `enum` listing all authentication implementations.
    enum Group { }
}

public extension Authenticator where Storage == TransientStorage<Secret> {
    /// The default transient `Authenticator`.
    static var transient: Authenticator {
        transient(with: .default)
    }

    /// A transient `Authenticator` with a specific `Client`.
    ///
    /// - parameter client: A valid `Client`.
    /// - returns: A valid `Authenticator.`
    static func transient(with client: Client) -> Authenticator {
        .init(client: client)
    }

    /// Init.
    ///
    /// - parameter client: A valid `Client`. Defualts to `nil`.
    init(client: Client = .default) {
        self.init(storage: .init(), client: client)
    }
}

public extension Authenticator where Storage == UserDefaultsStorage<Secret> {
    /// The default user defaults-backed `Authenticator`.
    static var userDefaults: Authenticator {
        userDefaults(with: .default)
    }

    /// A user defaults-backed `Authenticator` with a specific `Client`.
    ///
    /// - parameter client: A valid `Client`.
    /// - returns: A valid `Authenticator.`
    static func userDefaults(with client: Client) -> Authenticator {
        .init(storage: .init(), client: client)
    }
}
