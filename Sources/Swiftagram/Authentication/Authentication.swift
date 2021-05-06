//
//  Authentication.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 09/04/21.
//

import Foundation

/// A `protocol` defining a generic authentication process.
public protocol Authentication {
    /// Authenticate the given user.
    ///
    /// - returns: A valid `Publisher`.
    func authenticate() -> AnyPublisher<Secret, Error>
}

/// A `protocol` defining an authentication process to be executed mimicing a custom `Client`.
public protocol CustomClientAuthentication: Authentication {
    /// Authenticate the given user.
    ///
    /// - parameter client: A valid `Client`.
    /// - returns: A valid `Publisher`.
    func authenticate(in client: Client) -> AnyPublisher<Secret, Error>
}

public extension CustomClientAuthentication {
    /// Authenticate the given user, with `Client.default`.
    ///
    /// - returns: A valid `Publisher`.
    func authenticate() -> AnyPublisher<Secret, Error> {
        authenticate(in: .default)
    }
}
