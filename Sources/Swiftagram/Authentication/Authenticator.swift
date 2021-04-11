//
//  Authenticator.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 09/04/21.
//

import Foundation

import ComposableStorage

/// A `struct` defining an instance capable of
/// starting the authentication flow for a given user.
public struct Authenticator {
    /// The underlying storage.
    public let storage: AnyStorage<Secret>
    /// The underlying client.
    public let client: Client

    /// Init.
    ///
    /// - parameters:
    ///     - storage: A valid `Storage`.
    ///     - client: A valid `Client`. Defaults to `.default`.
    public init<S: Storage>(storage: S, client: Client = .default) where S.Item == Secret {
        self.storage = AnyStorage(storage)
        self.client = client
    }
}

public extension Authenticator {
    /// An `enum` listing all authentication implementations.
    enum Group { }
}

public extension Authenticator {
    /// The default transient `Authenticator`.
    static var transient: Authenticator {
        transient(with: .default)
    }

    /// A transient `Authenticator` with a specific `Client`.
    ///
    /// - parameter client: A valid `Client`.
    /// - returns: A valid `Authenticator.`
    static func transient(with client: Client) -> Authenticator {
        .init(storage: TransientStorage<Secret>(), client: client)
    }

    /// The default user defaults-backed `Authenticator`.
    static var userDefaults: Authenticator {
        userDefaults(with: .default)
    }

    /// A user defaults-backed `Authenticator` with a specific `Client`.
    ///
    /// - parameters:
    ///     - userDefaults: A valid `UserDefaults`. Defaults to `.standard`.
    ///     - client: A valid `Client`.
    /// - returns: A valid `Authenticator.`
    static func userDefaults(_ userDefaults: UserDefaults = .standard, with client: Client) -> Authenticator {
        .init(storage: UserDefaultsStorage(userDefaults: userDefaults), client: client)
    }
}
