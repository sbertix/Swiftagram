//
//  TwoFactor.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//
import Foundation

import Swiftagram

/// A `class` defining 2FA challenge resolution for `BasicAuthenticator`.
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
    /// The underlying dispose bag.
    private var bin: Set<AnyCancellable> = []

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
        Request.version1.accounts
            .path(appending: "two_factor_login/")
            .appendingDefaultHeader()
            .header(appending: HTTPCookie.requestHeaderFields(with: [crossSiteRequestForgery]))
            .header(appending: ["X-IG-Device-ID": client.device.identifier.uuidString.lowercased(),
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
            .publish(session: .ephemeral)
            .sink(
                receiveCompletion: { if case .failure(let error) = $0 { self.onChange(.failure(error)) }},
                receiveValue: { item in
                    do {
                        let value = try Wrapper.decode(item.data)
                        guard !value.isEmpty, let response = item.response as? HTTPURLResponse else {
                            throw BasicAuthenticatorError.invalidResponse
                        }
                        // Prepare secret.
                        if value.loggedInUser.pk.int() != nil,
                           let url = URL(string: "https://instagram.com"),
                           let secret = Secret(
                            cookies: HTTPCookie.cookies(
                                withResponseHeaderFields: response.allHeaderFields as? [String: String] ?? [:],
                                for: url
                            ),
                            client: self.client
                           ) {
                            self.onChange(.success(secret))
                        } else if let error = value.errorType.string() {
                            // Otherwise check for errors.
                            throw BasicAuthenticatorError.custom(error)
                        } else {
                            throw BasicAuthenticatorError.invalidCookies
                        }
                    } catch {
                        self.onChange(.failure(error))
                    }
                }
            )
            .store(in: &bin)
    }
}
