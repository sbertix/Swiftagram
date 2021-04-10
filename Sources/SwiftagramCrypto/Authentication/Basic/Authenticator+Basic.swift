//
//  Authenticator+Basic.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 10/04/21.
//

import Foundation

import ComposableStorage
import SwCrypt

public extension Authenticator.Group {
    /// A `struct` defining an authentication relying
    /// on username and password and supporting
    /// two factor authentication.
    struct Basic: CustomClientAuthentication {
        /// The underlying authenticator.
        public let authenticator: Authenticator
        /// The username.
        public let username: String
        /// The password.
        private let password: String

        /// Init.
        ///
        /// - parameters:
        ///     - authenticator: A valid `Authenticator`.
        ///     - username: A valid `String`.
        ///     - password: A valid `String`.
        /// - note: Use `authenticator.basic(username:password:)` instead.
        fileprivate init(authenticator: Authenticator,
                         username: String,
                         password: String) {
            self.authenticator = authenticator
            self.username = username
            self.password = password
        }

        /// Authenticate the given user.
        ///
        /// - parameter client: A valid `Client`.
        /// - returns: A valid `Publisher`.
        public func authenticate(in client: Client) -> AnyPublisher<Secret, Swift.Error> {
            // Fetch unauthenticated header fields.
            Self.unauthenticatedHeader(for: client)
                .flatMap { cookies -> AnyPublisher<Secret, Swift.Error> in
                    // Make sure the CSRF token is set.
                    guard cookies.contains(where: { $0.name == "csrftoken" }) else {
                        return Fail(error: Authenticator.Error.invalidCookies(cookies)).eraseToAnyPublisher()
                    }
                    // Encrypt password.
                    return Self.encrypt(password: self.password,
                                        with: cookies,
                                        for: client)
                        .flatMap { Self.authenticate(username: self.username,
                                                     encryptedPassword: $0,
                                                     with: cookies,
                                                     for: client,
                                                     storedIn: self.authenticator.storage) }
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }

        /// Fetch unauthenticated header fields.
        ///
        /// - parameter client: A valid `Client`.
        /// - returns: Some `Publisher`.
        private static func unauthenticatedHeader(for client: Client) -> AnyPublisher<[HTTPCookie], Swift.Error> {
            Request.version1
                .accounts
                .read_msisdn_header
                .path(appending: "/")
                .appendingDefaultHeader()
                .header(appending: ["X-IG-Device-ID": client.device.identifier.uuidString.lowercased(),
                                    "X-IG-Android-ID": client.device.instagramIdentifier,
                                    "User-Agent": client.description,
                                    "X-DEVICE-ID": client.device.identifier.uuidString])
                .signing(body: ["mobile_subno_usage": "default",
                                "device_id": client.device.identifier.uuidString])
                .publish(session: .ephemeral)
                .tryMap {
                    if let headers = ($0.response as? HTTPURLResponse)?.allHeaderFields as? [String: String] { return headers }
                    throw Authenticator.Error.invalidResponse($0.response)
                }
                .map { HTTPCookie.cookies(withResponseHeaderFields: $0, for: URL(string: ".instagram.com")!) }
                .eraseToAnyPublisher()
        }

        /// Encrypt the user's password.
        ///
        /// - parameters:
        ///     - password: A valid `String`.
        ///     - cookies: An array of `HTTPCookie`s.
        ///     - client: A valid `Client`.

        /// - returns: Some `Publisher`.
        private static func encrypt(password: String,
                                    with cookies: [HTTPCookie],
                                    for client: Client) -> AnyPublisher<String, Swift.Error> {
            Request.version1
                .qe
                .sync
                .path(appending: "/")
                .appendingDefaultHeader()
                .header(appending: ["X-IG-Device-ID": client.device.identifier.uuidString.lowercased(),
                                    "X-IG-Android-ID": client.device.instagramIdentifier,
                                    "User-Agent": client.description,
                                    "X-DEVICE-ID": client.device.identifier.uuidString])
                .header(appending: HTTPCookie.requestHeaderFields(with: cookies))
                .signing(body: ["id": client.device.identifier.uuidString,
                                "experiments": Constants.loginExperiments])
                .publish(session: .ephemeral)
                .tryMap { result -> [String: String] in
                    guard let response = result.response as? HTTPURLResponse,
                          let header = response.allHeaderFields as? [String: String],
                          try Wrapper.decode(result.data).status.string() == "ok" else {
                        throw Authenticator.Error.invalidResponse(result.response)
                    }
                    return header
                }
                .tryMap { header -> String in
                    // Make sure encryption is available.
                    guard CC.RSA.available(), CC.GCM.available() else {
                        throw SigningError.cryptographyUnavailable
                    }
                    // Read kyes.
                    guard let passwordKeyId = header["ig-set-password-encryption-key-id"].flatMap(UInt8.init),
                          let passwordPublicKey = header["ig-set-password-encryption-pub-key"]
                            .flatMap({ Data(base64Encoded: $0) })
                            .flatMap({ String(data: $0, encoding: .utf8) }) else {
                        throw SigningError.invalidRepresentation
                    }
                    // Encrypt password.
                    let randomKey = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
                    let iv = Data((0..<12).map { _ in UInt8.random(in: 0...255) })
                    let time = "\(Int(Date().timeIntervalSince1970))"
                    // AES-GCM-256.
                    let (aesEncrypted, authenticationTag) = try CC.GCM.crypt(.encrypt,
                                                                             algorithm: .aes,
                                                                             data: password.data(using: .utf8)!,
                                                                             key: randomKey,
                                                                             iv: iv,
                                                                             aData: time.data(using: .utf8)!,
                                                                             tagLength: 16)
                    // RSA.
                    let publicKey = try SwKeyConvert.PublicKey.pemToPKCS1DER(passwordPublicKey)
                    let rsaEncrypted = try CC.RSA.encrypt(randomKey,
                                                          derKey: publicKey,
                                                          tag: .init(),
                                                          padding: .pkcs1,
                                                          digest: .none)
                    var rsaEncryptedLELength = UInt16(littleEndian: UInt16(rsaEncrypted.count))
                    let rsaEncryptedLength = Data(bytes: &rsaEncryptedLELength, count: MemoryLayout<UInt16>.size)
                    // Compute `enc_password`.
                    var data = Data()
                    data.append(1)
                    data.append(passwordKeyId)
                    data.append(iv)
                    data.append(rsaEncryptedLength)
                    data.append(rsaEncrypted)
                    data.append(authenticationTag)
                    data.append(aesEncrypted)
                    return "#PWD_INSTAGRAM:4:\(time):\(data.base64EncodedString())"
                }
                .eraseToAnyPublisher()
        }

        /// Authenticate the given user.
        ///
        /// - parameters:
        ///     - username: A valid `String`.
        ///     - encryptedPassword: A valid `String`.
        ///     - cookies: An array of `HTTPCookie`s.
        ///     - client: A valid `Client`.
        ///     - storage: A valid `Storage`.
        /// - returns: Some `Publisher`.
        private static func authenticate<S: Storage>(username: String,
                                                     encryptedPassword: String,
                                                     with cookies: [HTTPCookie],
                                                     for client: Client,
                                                     storedIn storage: S) -> AnyPublisher<Secret, Swift.Error> where S.Item == Secret {
            // Check for cross site request forgery token.
            guard let crossSiteRequestForgery = cookies.first(where: { $0.name == "csrftoken" }) else {
                return Fail(error: Authenticator.Error.invalidCookies(cookies)).eraseToAnyPublisher()
            }
            // Obtain authenticated cookies.
            return Request.version1
                .accounts
                .login
                .path(appending: "/")
                .appendingDefaultHeader()
                .header(appending: ["X-IG-Device-ID": client.device.identifier.uuidString.lowercased(),
                                    "X-IG-Android-ID": client.device.instagramIdentifier,
                                    "User-Agent": client.description,
                                    "X-Csrf-Token": crossSiteRequestForgery.value])
                .signing(body: [
                    "username": username,
                    "enc_password": encryptedPassword,
                    "guid": client.device.identifier.uuidString,
                    "phone_id": client.device.phoneIdentifier.uuidString,
                    "device_id": client.device.instagramIdentifier,
                    "adid": "",
                    "google_tokens": "[]",
                    "country_codes": #"[{"country_code":"1","source": "default"}]"#,
                    "login_attempt_count": "0",
                    "jazoest": "2\(client.device.phoneIdentifier.uuidString.data(using: .ascii)!.reduce(0) { $0+Int($1) })"
                ])
                .publish(session: .ephemeral)
                .tryMap { result throws -> Secret in
                    let value = try Wrapper.decode(result.data)
                    // Make sure the response is correct.
                    guard !value.isEmpty, let response = result.response as? HTTPURLResponse else {
                        throw Authenticator.Error.invalidResponse(result.response)
                    }
                    // Deal with two factor authentication.
                    if let twoFactorIdentifier = value.twoFactorInfo.twoFactorIdentifier.string() {
                        throw Authenticator.Error.twoFactorChallenge(.init(storage: storage,
                                                                           client: client,
                                                                           identifier: twoFactorIdentifier,
                                                                           username: username,
                                                                           crossSiteRequestForgery: crossSiteRequestForgery))
                    } else if let error = value.errorType.string() {
                        switch error {
                        case "bad_password":
                            throw Authenticator.Error.invalidPassword
                        case "invalid_user":
                            throw Authenticator.Error.invalidUsername
                        default:
                            throw Authenticator.Error.generic(error)
                        }
                    } else if value.loggedInUser.pk.int() != nil, let url = URL(string: "https://instagram.com") {
                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: (response.allHeaderFields as? [String: String]) ?? [:],
                                                         for: url)
                        guard let secret = Secret(cookies: cookies, client: client) else { throw Authenticator.Error.invalidCookies(cookies) }
                        return try S.store(secret, in: storage)
                    } else {
                        throw Authenticator.Error.invalidResponse(response)
                    }
                }
                .eraseToAnyPublisher()
        }
    }
}

public extension Authenticator {
    /// Authenticate using username and password.
    ///
    /// 2FA is supported in code and it will be handled as an `Error`
    /// in the authentication stream, returning a `TwoFactorComposer`
    /// authenticator.
    ///
    /// - parameters:
    ///     - username: A valid `String`.
    ///     - password: A valid `String`.
    /// - returns: A valid `Group.Basic`.
    func basic(username: String, password: String) -> Group.Basic {
        .init(authenticator: self, username: username, password: password)
    }
}
