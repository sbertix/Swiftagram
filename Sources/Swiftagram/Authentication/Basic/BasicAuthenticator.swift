//
//  BasicAuthenticator.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

import ComposableRequest
import SwCrypt

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
    internal var userAgent: String = ["Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_3 like Mac OS X)",
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

    // MARK: Authenticator
    /// Return a `Secret` and store it in `storage`.
    /// - parameter onChange: A block providing a `Secret`.
    public func authenticate(_ onChange: @escaping (Result<Secret, Swift.Error>) -> Void) {
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        // Update values.
        Endpoint.version1.qe.sync.appending(path: "/")
            .appendingDefaultHeader()
            .appending(header: "X-DEVICE-ID", with: Device.default.deviceGUID.uuidString)
            .signing(body: ["id": Device.default.deviceGUID.uuidString,
                            "experiments": Constants.loginExperiments])
            .prepare()
            .debugTask { [self] in
                guard let response = $0.response else { return onChange(.failure(AuthenticatorError.invalidResponse)) }
                switch $0.value {
                case .failure(let error): onChange(.failure(error))
                case .success(let value) where value.status.string() == "ok":
                    // Process headers and handle encryption.
                    switch self.encryptPassword(with: response.allHeaderFields as? [String: String] ?? [:]) {
                    case .failure(let error): onChange(.failure(error))
                    case .success(let encrypted):
                        // Request authentication.
                        self.authenticate(with: encrypted,
                                          header: response.allHeaderFields,
                                          onChange: onChange)
                    }
                default: onChange(.failure(AuthenticatorError.invalidResponse))
                }
            }
            .resume()
    }

    // MARK: Shared flow
    /// Encrypt `password`.
    private func encryptPassword(with header: [String: String]) -> Result<(timestamp: String, password: String), Swift.Error> {
        guard let passwordKeyId = header["ig-set-password-encryption-key-id"],
            let passwordPublicKey = header["ig-set-password-encryption-pub-key"]
                .flatMap({ Data(base64Encoded: $0).flatMap { String(data: $0, encoding: .utf8) }}) else {
                    return .failure(AuthenticatorError.invalidResponse)
        }
        // Encrypt.
        let randomKey = (0..<32).map { _ in UInt8.random(in: 0...255) }
        let iv = (0..<12).map { _ in UInt8.random(in: 0...255) }
        let time = "\(Int(Date().timeIntervalSince1970))"
        do {
            // AES-GCM-256.
            let (aesEncrypted, authenticationTag) = try CC.GCM.crypt(.encrypt,
                                                                     algorithm: .aes,
                                                                     data: password.data(using: .utf8)!,
                                                                     key: Data(randomKey),
                                                                     iv: Data(iv),
                                                                     aData: time.data(using: .utf8)!,
                                                                     tagLength: 16)
            // RSA.
            let publicKey = try SwKeyConvert.PublicKey.pemToPKCS1DER(passwordPublicKey)
            let rsaEncrypted = try CC.RSA.encrypt(Data(randomKey),
                                                  derKey: publicKey,
                                                  tag: .init(),
                                                  padding: .pkcs1,
                                                  digest: .none)
            // Compute `enc_password`.
            var data = Data()
            data.append(contentsOf: [1]+passwordKeyId.data(using: .utf8)!.arrayOfBytes())
            data.append(contentsOf: iv)
            data.append(contentsOf: [0, 8])
            data.append(rsaEncrypted)
            data.append(authenticationTag)
            data.append(aesEncrypted)
            return .success((timestamp: time, password: data.base64EncodedString()))
        } catch {
            return .failure(error)
        }
    }
    
    /// Request authentication.
    private func authenticate(with encrypted: (timestamp: String, password: String),
                              header: [AnyHashable: Any],
                              onChange: @escaping (Result<Secret, Swift.Error>) -> Void) {
        // Check for cross site request forgery token.
        guard let crossSiteRequestForgery = HTTPCookie.cookies(withResponseHeaderFields: header as? [String: String] ?? [:],
                                                               for: URL(string: ".instagram.com")!)
            .first(where: { $0.name == "csrftoken" }) else {
                return onChange(.failure(AuthenticatorError.invalidCookies))
        }
        // Obtain the `ds_user_id` and the `sessionid`.
        Endpoint.generic.accounts.login.ajax
            .replacing(body: ["username": self.username,
                              "enc_password": "#PWD_INSTAGRAM:4:\(encrypted.timestamp):\(encrypted.password)"])
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
                self.process(result: $0,
                             crossSiteRequestForgery: crossSiteRequestForgery,
                             onChange: onChange)
            }
            .resume()
    }
    
    /// Handle `ds_user_id` and `sessionid` response.
    private func process(result: Result<Response, Swift.Error>,
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
