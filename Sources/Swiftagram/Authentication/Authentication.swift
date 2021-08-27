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
    /// - returns: A valid `Publisher`.
    func authenticate(in client: Client) -> Providers.Requester<Requester, Requester.Requested<Secret>>
}

/// A `protocol` defining a generic authentication process.
public protocol Authentication {
    /// The associated type.
    associatedtype Requester: Requests.Requester

    /// Authenticate the given user.
    ///
    /// - returns: A valid `Publisher`.
    func authenticate() -> Providers.Requester<Requester, Requester.Requested<Secret>>
}

public extension CustomClientAuthentication {
    /// Authenticate the given user, with `Client.default`.
    ///
    /// - returns: A valid `Publisher`.
    func authenticate() -> Providers.Requester<Requester, Requester.Requested<Secret>> {
        authenticate(in: .default)
    }
}
