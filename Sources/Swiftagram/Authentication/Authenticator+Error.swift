//
//  Authenticator+Error.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 10/04/21.
//

import Foundation

import Storages

public extension Authenticator {
    /// An `enum` listing some authentication-specific errors.
    enum Error: Swift.Error {
        /// Generic error.
        case generic(String)
        /// Invalid cookies.
        case invalidCookies([HTTPCookie])
        /// Invalid password.
        case invalidPassword
        /// Invalid response.
        case invalidResponse(URLResponse)
        /// Invalid URL.
        case invalidURL
        /// Invalid username.
        case invalidUsername
        /// Two factor authentication challenge.
        case twoFactorChallenge(TwoFactor)
    }
}

public extension Authenticator.Error {
    /// A `struct` defining a list of properties used for
    /// resolving a two factor authentication challenge.
    struct TwoFactor {
        /// The storage.
        public let storage: AnyStorage<Secret>
        /// The client.
        public let client: Client
        /// The challenge identifier.
        public let identifier: String
        /// The username.
        public let username: String
        /// The cross site request forgery token.
        public let crossSiteRequestForgery: HTTPCookie

        /// Init.
        ///
        /// - parameters:
        ///     - storage: Some `Storage`.
        ///     - client: A valid `Client`.
        ///     - identifier: A valid `String`.
        ///     - username: A valid `String`.
        ///     - crossSiteRequestForgery: A valid `HTTPCookie`.
        public init<S: Storage>(storage: S,
                                client: Client,
                                identifier: String,
                                username: String,
                                crossSiteRequestForgery: HTTPCookie) where S.Item == Secret {
            self.storage = AnyStorage(storage)
            self.client = client
            self.identifier = identifier
            self.username = username
            self.crossSiteRequestForgery = crossSiteRequestForgery
        }
    }
}
