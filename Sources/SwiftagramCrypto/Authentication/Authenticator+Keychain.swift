//
//  Authenticator+Keychain.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 09/04/21.
//

import Foundation

import ComposableStorageCrypto

/// A `typealias` for `ComposableStorageCrypto.Keychain`.
///
/// - note:
///     We prefer this to `import @_exported`, as we can't guarantee `@_exported`
///     to stick with future versions of **Swift**.
public typealias Keychain = ComposableStorageCrypto.Keychain

public extension Authenticator {
    /// The default keychain-backed `Authenticator`.
    static var keychain: Authenticator {
        keychain(with: .default)
    }

    /// A keychain-backed `Authenticator` with a specific `Client`.
    ///
    /// - parameters:
    ///     - keychain: A valid `Keychain`. Defaults to `.init()`.
    ///     - client: A valid `Client`.
    /// - returns: A valid `Authenticator.`
    static func keychain(_ keychain: Keychain = .init(),
                         with client: Client) -> Authenticator {
        .init(storage: KeychainStorage(service: keychain.service,
                                       group: keychain.group,
                                       accessibility: keychain.accessibility,
                                       authentication: keychain.authentication,
                                       isSynchronizable: keychain.isSynchronizable),
              client: client)
    }
}
