//
//  Authenticator.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

/// A `protocol` describing a form of fetching `Authentication.Response`s.
public protocol Authenticator {
    /// A `Storage` concrete type in which `Authentication.Response` are stored.
    associatedtype Storage: Swiftagram.Storage
    /// A `Storage` instance used to store `Authentication.Response`s.
    var storage: Storage { get }
    
    /// Return an `Authentication.Response` and store it in `storage`.
    /// - parameter onComplete: A block providing a `Result<Authentication.Response, Error>`.
    /// - warning: Always call `Authentication.Response.store` with `storage` when receiving the `Authentication.Response` .
    /// - note: Using `TransientStorage` as `Storage` allows to disregard any storing mechanism.
    func authenticate(_ onComplete: @escaping (Result<Authentication.Response, Error>) -> Void)
}

/// A `class` describing an `Authenticator` using `username` and `password`.
public final class BasicAuthenticator<Storage: Swiftagram.Storage>: Authenticator {
    /// An `enum` holding reference to `BasicAuthenticator`-specific `Error`s.
    public enum Error: Swift.Error {
        /// Invalid cookies.
        case invalidCookies
        /// Invalid response.
        case invalidResponse
        /// Weak reference released.
        case weakReferenceReleased
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
            .onDataComplete { [weak self] in
                switch $0 {
                case .failure(let error): onComplete(.failure(error))
                case .success(let value):
                    // Obtain the `csrftoken`.
                    guard let response = value.response else {
                        return onComplete(.failure(Error.invalidResponse))
                    }
                    let headerFields = response.allHeaderFields as? [String: String] ?? [:]
                    guard let crossSiteRequestForgery = HTTPCookie.cookies(withResponseHeaderFields: headerFields,
                                                                           for: response.url!)
                        .first(where: { $0.name == "csrftoken" })?
                        .value else {
                            return onComplete(.failure(Error.invalidResponse))
                    }
                    // Check for reference.
                    guard let me = self else {
                        return onComplete(.failure(Error.weakReferenceReleased))
                    }
                    // Request the `sessionid` and the `ds_user_id`.
                    Request(
                        Endpoint.generic.accounts.login.ajax
                            .body(key: "username", value: me.username)
                            .body(key: "password", value: me.password)
                            .headerFields(
                                ["X-Instagram-AJAX": "1",
                                 "X-CSRFToken": crossSiteRequestForgery,
                                 "X-Requested-With": "XMLHttpRequest",
                                 "Referer": "https://instagram.com/"]
                            )
                    )
                    .onComplete {
                        switch $0 {
                        case .failure(let error): onComplete(.failure(error))
                        case .success(let value):
                            // Check for `ds_user_id` and `sessionid`.
                            if value.authenticated.bool ?? false,
                                let identifier = value.userId.string,
                                let session = HTTPCookieStorage.shared.cookies?.first(where : {
                                    $0.name == "sessionid" && $0.domain.contains(".instagram.com")
                                })?.value {
                                // Return the `Authentication.Response`.
                                onComplete(.success(.init(identifier: identifier,
                                                          crossSiteRequestForgery: crossSiteRequestForgery,
                                                          session: session)))
                            } else {
                                // TODO: Add challenges, two factor authentication, etc.
                                return onComplete(.failure(Error.invalidCookies))
                            }
                        }
                    }
                    .resume()
                }
            }
            .resume()
    }
}
