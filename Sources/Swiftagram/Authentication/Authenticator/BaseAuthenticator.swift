//
//  BaseAuthenticator.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

/// A `class` describing an `Authenticator` using `username` and `password`.
public final class BasicAuthenticator<Storage: Swiftagram.Storage>: Authenticator {
    /// An `enum` holding reference to `BasicAuthenticator`-specific `Error`s.
    public enum Error: Swift.Error {
        /// Checkpoint encountered. Open the `Instagram` app.
        case checkpoint
        /// Invalid cookies.
        case invalidCookies
        /// Invalid password.
        case invalidPassword
        /// Invalid response.
        case invalidResponse
        /// Invalid username.
        case invalidUsername
        /// Two factor challenge encountered
        case twoFactor
    }

    /// A `Storage` instance used to store `Authentication.Response`s.
    public internal(set) var storage: Storage
    /// A `String` holding a valid username.
    public internal(set) var username: String
    /// A `String` holding a valid password.
    public internal(set) var password: String

    // MARK: Lifecycle
    /// Init.
    /// - parameter storage: A concrete `Storage` value.
    /// - parameter username: A `String` representing a valid username.
    /// - parameter password: A `String` representing a valid password.
    public init(storage: Storage, username: String, password: String) {
        self.storage = storage
        self.username = username
        self.password = password
    }

    // MARK: Authenticator
    /// Return an `Authentication.Response` and store it in `storage`.
    /// - parameter onComplete: A block providing an `Authentication.Response`.
    public func authenticate(_ onComplete: @escaping (Result<Authentication.Response, Swift.Error>) -> Void) {
        /// Remove all cookies.
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        /// Log in.
        Request(.generic)
            .onDataComplete { [self] in
                switch $0 {
                case .failure(let error): onComplete(.failure(error))
                case .success(let value):
                    // Obtain the `csrftoken`.
                    guard let response = value.response else {
                        return onComplete(.failure(Error.invalidResponse))
                    }
                    let headerFields = (response.allHeaderFields as? [String: String]) ?? [:]
                    guard let crossSiteRequestForgery = HTTPCookie.cookies(withResponseHeaderFields: headerFields,
                                                                           for: response.url!)
                        .first(where: { $0.name == "csrftoken" }) else {
                            return onComplete(.failure(Error.invalidCookies))
                    }
                    // Obtain the `ds_user_id` and the `sessionid`.
                    Request(
                        Endpoint.generic.accounts.login.ajax
                            .body(["username": self.username,
                                   "password": self.password])
                            .headerFields(
                                ["Accept": "*/*",
                                 "Accept-Language": "en-US",
                                 "Accept-Encoding": "gzip, deflate",
                                 "Connection": "close",
                                 "x-csrftoken": crossSiteRequestForgery.value,
                                 "x-requested-with": "XMLHttpRequest",
                                 "Referer": "https://www.instagram.com",
                                 "Authority": "www.instagram.com",
                                 "Origin": "https://www.instagram.com",
                                 "Content-Type": "application/x-www-form-urlencoded"]
                            )
                    )
                    .onComplete {
                        switch $0 {
                        case .failure(let error): onComplete(.failure(error))
                        case .success(let value):
                            // Check for authentication.
                            if let checkpoint = value.data.checkpointUrl.string {
                                print(value.data.beautifiedDescription, value.response as Any)
                                // TODO: resolve checkpoint.
                                Request(
                                    Endpoint.generic.wrap(checkpoint.trimmingCharacters(in: .init(charactersIn: "/")))
                                )
                                .onComplete {
                                    print($0)
                                    onComplete(.failure(Error.checkpoint))
                                }
                                .resume()
                            } else if value.data.twoFactorInfo != .none {
                                print(value.data.beautifiedDescription, value.response as Any)
                                // TODO: resolve two factor authentication.
                                onComplete(.failure(Error.twoFactor))
                            } else if value.data.user.bool.flatMap({ !$0 }) ?? false {
                                onComplete(.failure(Error.invalidUsername))
                            } else if value.data.authenticated.bool ?? false,
                                let headerFields = value.response?.allHeaderFields as? [String: String],
                                let url = value.response?.url {
                                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields,
                                                                 for: url)
                                    .filter { ["sessionid", "ds_user_id"].contains($0.name) && $0.domain.contains(".instagram.com") }
                                    .sorted { $0.name < $1.name }
                                guard cookies.count == 2 else {
                                    return onComplete(.failure(Error.invalidCookies))
                                }
                                // Complete.
                                onComplete(.success(.init(identifier: cookies[0],
                                                          crossSiteRequestForgery: crossSiteRequestForgery,
                                                          session: cookies[1])))
                            } else if value.data.authenticated.bool.flatMap({ !$0 }) ?? false {
                                onComplete(.failure(Error.invalidPassword))
                            } else {
                                print(value.data.beautifiedDescription, value.response as Any)
                                onComplete(.failure(Error.invalidResponse))
                            }
                        }
                    }
                    .resume()
                }
            }
            .resume()
    }
}

/// Extend for `TransientStorage`.
public extension BasicAuthenticator where Storage == TransientStorage {
    // MARK: Lifecycle
    /// Init.
    /// - parameter username: A `String` representing a valid username.
    /// - parameter password: A `String` representing a valid password.
    convenience init(username: String, password: String) {
        self.init(storage: .init(), username: username, password: password)
    }
}
