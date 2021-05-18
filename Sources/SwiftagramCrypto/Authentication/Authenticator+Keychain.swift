//
//  Authenticator+Keychain.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 09/04/21.
//

import Foundation

import ComposableStorageCrypto

/// A `typealias` for `ComposableStorageCrypto.KeychainStorage`.
///
/// - note:
///     We prefer this to `import @_exported`, as we can't guarantee `@_exported`
///     to stick with future versions of **Swift**.
public typealias KeychainStorage = ComposableStorageCrypto.KeychainStorage

public extension Authenticator {
    /// The default keychain-backed `Authenticator`.
    static var keychain: Authenticator {
        keychain(.init())
    }

    /// A keychain-backed `Authenticator`.
    ///
    /// - parameter keychain: A valid `KeychainStorage`.
    /// - returns: A valid `Authenticator.`
    static func keychain(_ keychainStorage: KeychainStorage<Secret>) -> Authenticator {
        self.init(storage: keychainStorage)
    }
}
