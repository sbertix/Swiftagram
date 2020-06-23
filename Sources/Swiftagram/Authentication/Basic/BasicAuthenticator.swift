//
//  BasicAuthenticator.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

import ComposableRequest

/**
    A `class` describing an `Authenticator` using `username` and `password`.
 */
public final class BasicAuthenticator<Storage: Swiftagram.Storage> {
    // MARK: Lifecycle
    @available(*, unavailable, message: "Instagram changes broke the implementation. Please use `WebViewAuthenticator` in the meantime.")
    /// Init.
    /// - parameters:
    ///     - storage: A concrete `Storage` value.
    ///     - username: A `String` representing a valid username.
    ///     - password: A `String` representing a valid password.
    public init(storage: Storage, username: String, password: String) {
        fatalError("Removed implementation because of Instagram changes.")
    }

    /// Set `userAgent`.
    /// - parameter userAgent: A `String` representing a valid user agent.
    public func userAgent(_ userAgent: String?) -> BasicAuthenticator<Storage> {
        return self
    }

    /// Update `userAgent` with the `Device.default`'s one.
    public func defaultDeviceUserAgent() -> BasicAuthenticator<Storage> {
        return self
    }

    // MARK: Authenticator
    /// Return a `Secret` and store it in `storage`.
    /// - parameter onChange: A block providing a `Secret`.
    @available(*, unavailable, message: "Instagram changes broke the implementation. Please use `WebViewAuthenticator` in the meantime.")
    public func authenticate(_ onChange: @escaping (Result<Secret, Swift.Error>) -> Void) {
        fatalError("Removed implementation because of Instagram changes.")
    }
}

/// Extend for `TransientStorage`.
public extension BasicAuthenticator where Storage == TransientStorage {
    @available(*, unavailable, message: "Instagram changes broke the implementation. Please use `WebViewAuthenticator` in the meantime.")
    // MARK: Lifecycle
    /// Init.
    /// - parameters:
    ///     - username: A `String` representing a valid username.
    ///     - password: A `String` representing a valid password.
    convenience init(username: String, password: String) {
        fatalError("Removed implementation because of Instagram changes.")
    }
}
