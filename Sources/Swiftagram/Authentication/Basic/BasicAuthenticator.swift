//
//  BasicAuthenticator.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import ComposableRequest
import Foundation

/**
    A `class` describing an `Authenticator` using `username` and `password`.
 
    ## Usage
    ```swift
    /// A strong reference to a 2FA object.
    var twoFactor: TwoFactor? {
      didSet {
        guard let twoFactor = twoFactor else { return }
        // ask for the code and then pass it to `twoFactor.send`.
      }
    }
    /// A strong reference to a Checkpoint object.
    var checkpoint: Checkpoint? {
      didSet {
        guard let checkpoint = checkpoint else { return }
        // ask for validation method then pass it to `checkpoint.request`,
        // before sending the code to through `checkpoint.send`.
      }
    }
 
    /// Login.
    BasicAuthenticator(storage: KeychainStorage(),  // any `Storage`.
                       username: /* the username */,
                       password: /* the password */)
      .authenticate {
        switch $0 {
        case .failure(let error):
          switch error {
            case AuthenticatorError.checkpoint(let response): checkpoint = response
            case AuthenticatorError.twoFactor(let response): twoFactor = response
            default: print(error)
          }
        case .success: print("Logged in")
      }
    ```
 */
public final class BasicAuthenticator<Storage: Swiftagram.Storage>: Authenticator {
    /// A `Storage` instance used to store `Secret`s.
    public internal(set) var storage: Storage
    /// A `String` holding a valid username.
    public internal(set) var username: String
    /// A `String` holding a valid password.
    public internal(set) var password: String

    /// A `String` holding a custom user agent to be passed to every request.
    /// Defaults to Safari on an iPhone with iOS 13.1.3.
    public var userAgent: String = ["Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_3 like Mac OS X)",
                                    "AppleWebKit/605.1.15 (KHTML, like Gecko)",
                                    "Version/13.0.1 Mobile/15E148 Safari/604.1"].joined(separator: " ")

    // MARK: Lifecycle
    /// Init.
    /// - parameters:
    ///     - storage: A concrete `Storage` value.
    ///     - username: A `String` representing a valid username.
    ///     - password: A `String` representing a valid password.
    public init(storage: Storage, username: String, password: String) {
        self.storage = storage
        self.username = username
        self.password = password
    }

    /// Set `userAgent`.
    /// - parameter userAgent: A `String` representing a valid user agent.
    public func userAgent(_ userAgent: String?) -> BasicAuthenticator<Storage> {
        self.userAgent = userAgent
            ?? ["Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_3 like Mac OS X)",
                "AppleWebKit/605.1.15 (KHTML, like Gecko)",
                "Version/13.0.1 Mobile/15E148 Safari/604.1"].joined(separator: " ")
        return self
    }

    /// Update `userAgent` with the `Device.default`'s one.
    public func defaultDeviceUserAgent() -> BasicAuthenticator<Storage> {
        self.userAgent = Device.default.browserUserAgent
        return self
    }

    // MARK: Authenticator
    /// Return a `Secret` and store it in `storage`.
    /// - parameter onChange: A block providing a `Secret`.
    public func authenticate(_ onChange: @escaping (Result<Secret, Swift.Error>) -> Void) {
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        Endpoint.generic
            .appending(header: ["User-Agent": userAgent])
            .prepare { $0.map { String(data: $0, encoding: .utf8) ?? "" }}
            .debugTask(by: .authentication) { [self] in self.handleFirst(result: $0, onChange: onChange) }
            .resume()
    }

    // MARK: Shared flow
    /// Handle `csrftoken` response.
    private func handleFirst(result: Requester.Task.Response<String>,
                             onChange: @escaping (Result<Secret, Swift.Error>) -> Void) {
        // Check for value.
        switch result.value {
        case .failure(let error): onChange(.failure(error))
        case .success(let value):
            // Obtain the `csrftoken`.
            var crossSisteRequestForgery: HTTPCookie?
            // Check the response.
            if let response = result.response,
                let header = response.allHeaderFields as? [String: String],
                let url = response.url {
                crossSisteRequestForgery = HTTPCookie.cookies(withResponseHeaderFields: header,
                                                              for: url).first { $0.name == "csrftoken" }
            }
            // Check the default storage.
            if crossSisteRequestForgery == nil {
                crossSisteRequestForgery = HTTPCookieStorage.shared.cookies?.first { $0.name == "csrftoken" }
            }
            // Compute from `window`.
            if crossSisteRequestForgery == nil {
                crossSisteRequestForgery = value.components(separatedBy: #"csrf_token":""#)
                    .last?
                    .components(separatedBy: #"","viewer""#)
                    .first
                    .flatMap {
                        HTTPCookie(properties: [.name: "csrftoken",
                                                .value: $0,
                                                .domain: "instagram.com",
                                                .path: ""])
                    }
            }
            // Continue if needed.
            guard let crossSiteRequestForgery = crossSisteRequestForgery else {
                return onChange(.failure(AuthenticatorError.invalidCookies))
            }
            // Obtain the `ds_user_id` and the `sessionid`.
            Endpoint.generic.accounts.login.ajax
                .replacing(body: ["username": self.username,
                                "password": self.password])
                .replacing(header:
                    ["Accept": "*/*",
                     "Accept-Language": "en-US",
                     "Accept-Encoding": "gzip, deflate",
                     "Connection": "close",
                     "x-csrftoken": crossSiteRequestForgery.value,
                     "x-requested-with": "XMLHttpRequest",
                     "Referer": "https://www.instagram.com",
                     "Authority": "www.instagram.com",
                     "Origin": "https://www.instagram.com",
                     "Content-Type": "application/x-www-form-urlencoded",
                     "User-Agent": userAgent]
                )
                .prepare()
                .task(by: .authentication) { [self] in
                    self.handleSecond(result: $0,
                                      crossSiteRequestForgery: crossSiteRequestForgery,
                                      onChange: onChange)
                }
                .resume()
        }
    }

    /// Handle `ds_user_id` and `sessionid` response.
    private func handleSecond(result: Result<Response, Swift.Error>,
                              crossSiteRequestForgery: HTTPCookie,
                              onChange: @escaping (Result<Secret, Swift.Error>) -> Void) {
        switch result {
        case .failure(let error): onChange(.failure(error))
        case .success(let value):
            // Check for authentication.
            if let checkpoint = value.checkpointUrl.string() {
                // Handle the checkpoint.
                handleCheckpoint(checkpoint: checkpoint,
                                 crossSiteRequestForgery: crossSiteRequestForgery,
                                 onChange: onChange)
            } else if let twoFactorIdentifier = value.twoFactorInfo.twoFactorIdentifier.string() {
                // Handle 2FA.
                onChange(.failure(AuthenticatorError.twoFactor(.init(storage: storage,
                                                                     username: username,
                                                                     identifier: twoFactorIdentifier,
                                                                     userAgent: Device.default.browserUserAgent,
                                                                     crossSiteRequestForgery: crossSiteRequestForgery,
                                                                     onChange: onChange))))
            } else if value.user.bool().flatMap({ !$0 }) ?? false {
                // User not found.
                onChange(.failure(AuthenticatorError.invalidUsername))
            } else if value.authenticated.bool() ?? false {
                // User authenticated successfuly.
                let instagramCookies = HTTPCookieStorage.shared.cookies?
                    .filter { $0.domain.contains(".instagram.com") }
                    .sorted { $0.name < $1.name } ?? []
                guard instagramCookies.count >= 2 else {
                    return onChange(.failure(AuthenticatorError.invalidCookies))
                }
                // Complete.
                let cookies = Secret.hasValidCookies(instagramCookies)
                    ? instagramCookies
                    : instagramCookies+[crossSiteRequestForgery]
                onChange(Secret(cookies: cookies).flatMap { .success($0.store(in: self.storage)) }
                    ?? .failure(Secret.Error.invalidCookie))
            } else if value.authenticated.bool().flatMap({ !$0 }) ?? false {
                // User not authenticated.
                onChange(.failure(AuthenticatorError.invalidPassword))
            } else {
                onChange(.failure(AuthenticatorError.invalidResponse))
            }
        }
    }

    // MARK: Checkpoint flow
    /// Handle checkpoint.
    internal func handleCheckpoint(checkpoint: String,
                                   crossSiteRequestForgery: HTTPCookie,
                                   onChange: @escaping (Result<Secret, Swift.Error>) -> Void) {
        // Get checkpoint info.
        Endpoint.generic.appending(path: checkpoint)
            .replacing(header: ["User-Agent": userAgent])
            .prepare { $0.map { String(data: $0, encoding: .utf8) ?? "" }}
            .debugTask(by: .authentication) { [self] in
                // Check for errors.
                switch $0.value {
                case .failure(let error): onChange(.failure(error))
                case .success(let value):
                    // Notify checkpoint was reached.
                    guard let url = $0.response?.url,
                        value.contains("window._sharedData = ") else {
                            return onChange(.failure(AuthenticatorError.checkpoint(nil)))
                    }
                    guard let data = value
                        .components(separatedBy: "window._sharedData = ")[1]
                        .components(separatedBy: ";</script>")[0]
                        .data(using: .utf8),
                        let response = try? JSONDecoder().decode(Response.self, from: data) else {
                            return onChange(.failure(AuthenticatorError.checkpoint(nil)))
                    }
                    // Obtain available verification.
                    guard let verification = response
                        .entryData.challenge.array()?.first?
                        .extraData.content.array()?.last?
                        .fields.array()?.first?
                        .values.array()?
                        .compactMap(Verification.init) else {
                            return onChange(.failure(AuthenticatorError.checkpoint(nil)))
                    }
                    onChange(.failure(AuthenticatorError.checkpoint(Checkpoint(storage: self.storage,
                                                                               url: url,
                                                                               userAgent: Device.default.browserUserAgent,
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
    /// - parameters:
    ///     - username: A `String` representing a valid username.
    ///     - password: A `String` representing a valid password.
    convenience init(username: String, password: String) {
        self.init(storage: .init(), username: username, password: password)
    }
}
