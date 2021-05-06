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

    /// Init.
    ///
    /// - parameters:
    ///     - storage: A valid `Storage`.
    ///     - client: A valid `Client`. Defaults to `.default`.
    public init<S: Storage>(storage: S) where S.Item == Secret {
        self.storage = AnyStorage(storage)
    }
}

public extension Authenticator {
    /// An `enum` listing all authentication implementations.
    enum Group { }
}

public extension Authenticator {
    /// The default transient `Authenticator`.
    static var transient: Authenticator {
        .init(storage: TransientStorage())
    }

    /// The default user defaults-backed `Authenticator`.
    static var userDefaults: Authenticator {
        userDefaults(.standard)
    }

    /// A user defaults-backed `Authenticator` with a specific `Client`.
    ///
    /// - parameter userDefaults: A valid `UserDefaults`.
    /// - returns: A valid `Authenticator.`
    static func userDefaults(_ userDefaults: UserDefaults) -> Authenticator {
        .init(storage: UserDefaultsStorage(userDefaults: userDefaults))
    }
}
