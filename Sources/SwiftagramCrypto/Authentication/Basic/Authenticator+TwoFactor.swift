//
//  Authenticator+TwoFactor.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 10/04/21.
//

import Foundation

import ComposableStorage

public extension Authenticator.Group.Basic {
    /// A `struct` defining an instance capable of
    /// resolving a two factor authentication challenge.
    struct TwoFactor: Authentication {
        /// The storage.
        public let storage: AnyStorage<Secret>
        /// The client.
        public let client: Client
        /// The two factor authentication identfiier.
        private let identifier: String
        /// The code.
        public let code: String
        /// The username.
        public let username: String
        /// The cross stie request forgery token.
        public let crossSiteRequestForgery: HTTPCookie

        /// Init.
        ///
        /// - parameters:
        ///     - twoFactor: A valid `Authenticator.Error.TwoFactor`.
        ///     - code: A valid `String`.
        fileprivate init(twoFactor: Authenticator.Error.TwoFactor,
                         code: String) {
            self.storage = twoFactor.storage
            self.client = twoFactor.client
            self.identifier = twoFactor.identifier
            self.code = code
            self.username = twoFactor.username
            self.crossSiteRequestForgery =  twoFactor.crossSiteRequestForgery
        }

        /// Authenticate the given user.
        ///
        /// - parameters:
        ///     - username: A valid `String`.
        ///     - encryptedPassword: A valid `String`.
        ///     - cookies: An array of `HTTPCookie`s.
        ///     - client: A valid `Client`.
        /// - returns: Some `Publisher`.
        public func authenticate() -> AnyPublisher<Secret, Swift.Error> {
            Request.version1
                .accounts
                .path(appending: "two_factor_login/")
                .appendingDefaultHeader()
                .header(appending: HTTPCookie.requestHeaderFields(with: [crossSiteRequestForgery]))
                .header(appending: ["X-IG-Device-ID": client.device.identifier.uuidString.lowercased(),
                                    "X-IG-Android-ID": client.device.instagramIdentifier,
                                    "User-Agent": client.description,
                                    "X-Csrf-Token": crossSiteRequestForgery.value])
                .signing(body: [
                    "username": username,
                    "verification_code": code,
                    "_csrftoken": crossSiteRequestForgery.value,
                    "two_factor_identifier": identifier,
                    "trust_this_device": "1",
                    "guid": client.device.identifier.uuidString,
                    "device_id": client.device.instagramIdentifier,
                    "verification_method": "1"
                ])
                .publish(session: .ephemeral)
                .tryMap { result throws -> Secret in
                    let value = try Wrapper.decode(result.data)
                    guard value.isEmpty, let response = result.response as? HTTPURLResponse else {
                        throw Authenticator.Error.invalidResponse(result.response)
                    }
                    // Prepare the actual `Secret`.
                    if let error = value.errorType.string() {
                        throw Authenticator.Error.generic(error)
                    } else if value.loggedInUser.pk.int() != nil,
                              let url = URL(string: "https://instagram.com"),
                              let header = response.allHeaderFields as? [String: String] {
                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: url)
                        guard let secret = Secret(cookies: cookies, client: self.client) else {
                            throw Authenticator.Error.invalidResponse(result.response)
                        }
                        return try AnyStorage.store(secret, in: self.storage)
                    } else {
                        throw Authenticator.Error.invalidResponse(result.response)
                    }
                }
                .eraseToAnyPublisher()
        }
    }
}

public extension Authenticator.Error.TwoFactor {
    /// Update the code for the 2FA challenge.
    ///
    /// - parameter code: A valid `String`.
    /// - returns: A valid `Authenticator.Group.Basic.TwoFactor`.
    func code(_ code: String) -> Authenticator.Group.Basic.TwoFactor {
        .init(twoFactor: self, code: code)
    }
}
