//
//  BasicAuthenticator.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

/// A `class` describing an `Authenticator` using `username` and `password`.
public final class BasicAuthenticator<Storage: Swiftagram.Storage>: Authenticator {
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
    /// - parameter onChange: A block providing an `Authentication.Response`.
    public func authenticate(_ onChange: @escaping (Result<Authentication.Response, Swift.Error>) -> Void) {
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        Request(.generic)
            .onComplete { [self] in self.handleFirst(result: $0, onChange: onChange) }
            .resume()
    }

    // MARK: Shared flow
    /// Handle `csrftoken` response.
    private func handleFirst(result: Result<Requester.Task.Response<Response>, Swift.Error>,
                             onChange: @escaping (Result<Authentication.Response, Swift.Error>) -> Void) {
        switch result {
        case .failure(let error): onChange(.failure(error))
        case .success(let value):
            // Obtain the `csrftoken`.
            guard let response = value.response else {
                return onChange(.failure(AuthenticatorError.invalidResponse))
            }
            let headerFields = (response.allHeaderFields as? [String: String]) ?? [:]
            guard let crossSiteRequestForgery = HTTPCookie.cookies(withResponseHeaderFields: headerFields,
                                                                   for: response.url!)
                .first(where: { $0.name == "csrftoken" }) else {
                    return onChange(.failure(AuthenticatorError.invalidCookies))
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
            .onComplete { [self] in
                self.handleSecond(result: $0,
                                  crossSiteRequestForgery: crossSiteRequestForgery,
                                  onChange: onChange)
            }
            .resume()
        }
    }
    /// Handle `ds_user_id` and `sessionid` response.
    private func handleSecond(result: Result<Requester.Task.Response<Response>, Swift.Error>,
                              crossSiteRequestForgery: HTTPCookie,
                              onChange: @escaping (Result<Authentication.Response, Swift.Error>) -> Void) {
        switch result {
        case .failure(let error): onChange(.failure(error))
        case .success(let value):
            // Check for authentication.
            if let checkpoint = value.data.checkpointUrl.string {
                // Handle the checkpoint.
                handleCheckpoint(result: value,
                                 checkpoint: checkpoint,
                                 crossSiteRequestForgery: crossSiteRequestForgery,
                                 onChange: onChange)
            } else if let twoFactorIdentifier = value.data.twoFactorInfo.twoFactorIdentifier.string {
                // Handle 2FA.
                onChange(.failure(AuthenticatorError.twoFactor(.init(storage: storage,
                                                                     username: username,
                                                                     identifier: twoFactorIdentifier,
                                                                     crossSiteRequestForgery: crossSiteRequestForgery,
                                                                     onChange: onChange))))
            } else if value.data.user.bool.flatMap({ !$0 }) ?? false {
                // User not found.
                onChange(.failure(AuthenticatorError.invalidUsername))
            } else if value.data.authenticated.bool ?? false {
                // User authenticated successfuly.
                let cookies = HTTPCookieStorage.shared.cookies?
                    .filter { ["sessionid", "ds_user_id"].contains($0.name) && $0.domain.contains(".instagram.com") }
                    .sorted { $0.name < $1.name } ?? []
                guard cookies.count == 2 else {
                    return onChange(.failure(AuthenticatorError.invalidCookies))
                }
                // Complete.
                onChange(.success(Authentication.Response(identifier: cookies[0],
                                                          crossSiteRequestForgery: crossSiteRequestForgery,
                                                          session: cookies[1])
                    .store(in: self.storage)))
            } else if value.data.authenticated.bool.flatMap({ !$0 }) ?? false {
                // User not authenticated.
                onChange(.failure(AuthenticatorError.invalidPassword))
            } else {
                print(value.data.beautifiedDescription, value.response as Any)
                onChange(.failure(AuthenticatorError.invalidResponse))
            }
        }
    }

    // MARK: Checkpoint flow
    /// Handle checkpoint.
    private func handleCheckpoint(result: Requester.Task.Response<Response>,
                                  checkpoint: String,
                                  crossSiteRequestForgery: HTTPCookie,
                                  onChange: @escaping (Result<Authentication.Response, Swift.Error>) -> Void) {
        // Get checkpoint info.
        Request(
            Endpoint.generic.wrap(checkpoint)
        )
        .onCompleteString {
            // Check for errors.
            switch $0 {
            case .failure(let error): onChange(.failure(error))
            case .success(let value):
                // Notify checkpoint was reached.
                guard let url = value.response?.url,
                    value.data.contains("window._sharedData = ") else {
                        return onChange(.failure(AuthenticatorError.checkpoint(nil)))
                }
                guard let data = value.data
                    .components(separatedBy: "window._sharedData = ")[1]
                    .components(separatedBy: ";</script>")[0]
                    .data(using: .utf8),
                    let response = try? Response(data: data) else {
                        return onChange(.failure(AuthenticatorError.checkpoint(nil)))
                }
                // Obtain available verification.
                guard let verification = response
                    .entryData.challenge.array?.first?
                    .extraData.content.array?.last?
                    .fields.array?.first?
                    .values.array?
                    .compactMap(Verification.init) else {
                        return onChange(.failure(AuthenticatorError.checkpoint(nil)))
                }
                onChange(.failure(AuthenticatorError.checkpoint(Checkpoint(storage: self.storage,
                                                                           url: url,
                                                                           crossSiteRequestForgery: crossSiteRequestForgery,
                                                                           availableVerification: Set(verification),
                                                                           onChange: onChange))))
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
