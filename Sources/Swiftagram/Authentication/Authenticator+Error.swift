//
//  Authenticator+Error.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 10/04/21.
//

import Foundation

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
        /// The authenticator..
        public let authenticator: Authenticator
        /// The challenge identifier.
        public let identifier: String
        /// The username.
        public let username: String
        /// The cross site request forgery token.
        public let crossSiteRequestForgery: HTTPCookie

        /// Init.
        ///
        /// - parameters:
        ///     - authenticator: A valid `Authenticator`.
        ///     - identifier: A valid `String`.
        ///     - username: A valid `String`.
        ///     - crossSiteRequestForgery: A valid `HTTPCookie`.
        public init(authenticator: Authenticator,
                    identifier: String,
                    username: String,
                    crossSiteRequestForgery: HTTPCookie) {
            self.authenticator = authenticator
            self.identifier = identifier
            self.username = username
            self.crossSiteRequestForgery = crossSiteRequestForgery
        }
    }
}
