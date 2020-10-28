//
//  TwoFactor.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//
import Foundation

import ComposableRequest
import Swiftagram

/// A `class` holding reference to a `TwoFactor`.
public final class TwoFactor {
    /// A `String` representing a user's username.
    let username: String
    /// The underlying `Client`.
    let client: Client
    /// A `String` representing the 2FA identifier.
    let identifier: String
    /// A `HTTPCookie` for `csrftoken`.
    let crossSiteRequestForgery: HTTPCookie
    /// A block providing a `Secret`.
    let onChange: (Result<Secret, Swift.Error>) -> Void

    // MARK: Lifecycle

    /// Init.
    ///
    /// - parameters:
    ///     - username: A valid `String`.
    ///     - client: A valid `Client`.
    ///     - identifier: A valid `String`.
    ///     - crossSiteRequestForgery: A valid `HTTPCookie`.
    ///     - onChange: A valid completion handler.
    init(username: String,
         client: Client,
         identifier: String,
         crossSiteRequestForgery: HTTPCookie,
         onChange: @escaping (Result<Secret, Swift.Error>) -> Void) {
        self.username = username
        self.client = client
        self.identifier = identifier
        self.crossSiteRequestForgery = crossSiteRequestForgery
        self.onChange = onChange
    }

    // MARK: 2FA flow

    /// Send the received code.
    ///
    /// - parameter code: A `String` containing the authentication code.
    public func send(code: String) {
        Endpoint.version1.accounts
            .appending(path: "two_factor_login/")
            .appendingDefaultHeader()
            .appending(header: HTTPCookie.requestHeaderFields(with: [crossSiteRequestForgery]))
            .appending(header: ["X-IG-Device-ID": client.device.identifier.uuidString.lowercased(),
                                "X-IG-Android-ID": client.device.instagramIdentifier,
                                "User-Agent": client.description,
                                "X-Csrf-Token": crossSiteRequestForgery.value])
            .signing(body: [
                "username": self.username,
                "verification_code": code,
                "_csrftoken": crossSiteRequestForgery.value,
                "two_factor_identifier": identifier,
                "trust_this_device": "1",
                "guid": Client.default.device.identifier.uuidString,
                "device_id": Client.default.device.instagramIdentifier,
                "verification_method": "1"
            ])
            .prepare()
            .debugTask(by: .authentication) { [self] result in
                switch result.value {
                case .failure(let error): self.onChange(.failure(error))
                case .success(let value):
                    // Return secret.
                    if value.loggedInUser.pk.int() != nil,
                       let url = URL(string: "https://instagram.com"),
                       let secret = Secret(
                        cookies: HTTPCookie.cookies(
                            withResponseHeaderFields: result.response?.allHeaderFields as? [String: String] ?? [:],
                            for: url
                        ),
                        client: self.client
                       ) {
                        self.onChange(.success(secret))
                    }
                    // Otherwise check for error.
                    else if let error = value.errorType.string() {
                        self.onChange(.failure(BasicAuthenticatorError.custom(error)))
                    } else { self.onChange(.failure(BasicAuthenticatorError.invalidCookies)) }
                }
            }
            .resume()
    }
}
