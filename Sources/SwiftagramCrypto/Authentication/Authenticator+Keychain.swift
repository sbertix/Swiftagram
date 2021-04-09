//
//  Authenticator+Keychain.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 09/04/21.
//

import Foundation

public extension Authenticator where Storage == KeychainStorage<Secret> {
    /// The default keychain-backed `Authenticator`.
    static var keychain: Authenticator {
        keychain(with: .default)
    }

    /// A keychain-backed `Authenticator` with a specific `Client`.
    ///
    /// - parameter client: A valid `Client`.
    /// - returns: A valid `Authenticator.`
    static func keychain(with client: Client) -> Authenticator {
        .init(storage: .init(), client: client)
    }
}
