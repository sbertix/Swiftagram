//
//  TwoFactor.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

/// A `class` holding reference to a `TwoFactor`.
public final class TwoFactor {
    /// Any `Storage`.
    internal let storage: Storage
    /// A `String` representing a user's username.
    internal let username: String
    /// A `String` representing the 2FA identifier.
    internal let identifier: String
    /// A `String` representing the user agent to be used for every request.
    internal let userAgent: String
    /// A `HTTPCookie` for `csrftoken`.
    internal let crossSiteRequestForgery: HTTPCookie
    /// A block providing a `Secret`.
    internal let onChange: (Result<Secret, Swift.Error>) -> Void

    // MARK: Lifecycle
    /// Init.
    internal init<Storage: Swiftagram.Storage>(storage: Storage,
                                               username: String,
                                               identifier: String,
                                               userAgent: String,
                                               crossSiteRequestForgery: HTTPCookie,
                                               onChange: @escaping (Result<Secret, Swift.Error>) -> Void) {
        self.storage = storage
        self.username = username
        self.identifier = identifier
        self.userAgent = userAgent
        self.crossSiteRequestForgery = crossSiteRequestForgery
        self.onChange = onChange
    }

    // MARK: 2FA flow
    /// Send the received code.
    /// - parameter code: A `String` containing the authentication code.
    public func send(code: String) {
        Endpoint.generic.accounts.login.ajax.two_factor
            .replacing(body: ["username": username,
                              "verificationCode": code,
                              "identifier": identifier])
            .replacing(header:
                ["Accept": "*/*",
                 "Accept-Language": "en-US",
                 "Accept-Encoding": "gzip, deflate",
                 "Connection": "close",
                 "x-csrftoken": crossSiteRequestForgery.value,
                 "x-requested-with": "XMLHttpRequest",
                 "Referer": "https://www.instagram.com/accounts/login/ajax/two_factor/",
                 "Authority": "www.instagram.com",
                 "Content-Type": "application/x-www-form-urlencoded",
                 "User-Agent": userAgent]
            )
            .prepare(processor: { $0.map { String(data: $0, encoding: .utf8) }})
            .debugTask(by: .authentication) { [self] in
                switch $0.value {
                case .failure(let error): self.onChange(.failure(error))
                case .success:
                    switch $0.response?.statusCode {
                    case 200:
                        // Fetch `Secret`.
                        let instagramCookies = HTTPCookieStorage.shared.cookies?
                            .filter { ["sessionid", "ds_user_id"].contains($0.name) && $0.domain.contains(".instagram.com") }
                            .sorted { $0.name < $1.name } ?? []
                        guard instagramCookies.count == 2 else {
                            return self.onChange(.failure(AuthenticatorError.invalidCookies))
                        }
                        // Complete.
                        let cookies = Secret.hasValidCookies(instagramCookies)
                            ? instagramCookies
                            : instagramCookies+[self.crossSiteRequestForgery]
                        self.onChange(Secret(cookies: cookies).flatMap { .success($0.store(in: self.storage)) }
                            ?? .failure(Secret.Error.invalidCookie))
                    case 400:
                        // Invalid code.
                        self.onChange(.failure(AuthenticatorError.invalidCode))
                    default:
                        // Invalid response.
                        self.onChange(.failure(AuthenticatorError.invalidResponse))
                    }
                }
            }
            .resume()
    }
}
