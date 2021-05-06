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
        keychain(.init())
    }

    /// A keychain-backed `Authenticator`.
    ///
    /// - parameter keychain: A valid `Keychain`. Defaults to `.init()`.
    /// - returns: A valid `Authenticator.`
    static func keychain(_ keychain: Keychain = .init()) -> Authenticator {
        .init(storage: KeychainStorage(service: keychain.service,
                                       group: keychain.group,
                                       accessibility: keychain.accessibility,
                                       authentication: keychain.authentication,
                                       isSynchronizable: keychain.isSynchronizable))
    }
}
