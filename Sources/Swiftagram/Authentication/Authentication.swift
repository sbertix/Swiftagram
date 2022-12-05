//
//  Authentication.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 09/04/21.
//

import Foundation

/// A `protocol` defining an authentication process to be executed mimicing a custom `Client`.
public protocol CustomClientAuthentication: Authentication {
    /// Authenticate the given user.
    ///
    /// - parameter client: A valid `Client`.
    /// - returns: Some `SingleEndpoint`.
    func authenticate(in client: Client) -> AnySingleEndpoint<Secret>
}

/// A `protocol` defining a generic authentication process.
public protocol Authentication {
    /// Authenticate the given user.
    ///
    /// - returns: Some `SingleEndpoint.`
    func authenticate() -> AnySingleEndpoint<Secret>
}

public extension CustomClientAuthentication {
    /// Authenticate the given user, with `Client.default`.
    ///
    /// - returns: Some `SingleEndpoint`.
    func authenticate() -> AnySingleEndpoint<Secret> {
        authenticate(in: .default)
    }
}
