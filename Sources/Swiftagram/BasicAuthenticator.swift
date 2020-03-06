//
//  BasicAuthenticator.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

/// A `protocol` defining an abastract authenticator.
internal protocol Authenticator {
    /// The current state.
    var state: Result<[HTTPCookie], Error>? { get set }
    /// An optional block to be called everytime `state` is updated.
    var onStateChange: ((Result<[HTTPCookie], Error>) -> Void)? { get set }
    
    /// Authenticate.
    func authenticate(onStateChange: @escaping (Result<[HTTPCookie], Error>) -> Void)
}

/// A `class` defining everything needed for a `username` and `password`-based authentication.
public final class BasicAuthenticator: Authenticator {
    /// An `enum` defining Two Factor Authentication available media.
    public enum Medium: Hashable {
        /// Email.
        case email
        /// Mobile phone.
        case phone
    }
    /// An `enum` defining all specific `Error`s.
    public enum Error: Swift.Error {
        /// Already authenticating.
        case authenticating
        /// Challenge encountered.
        case challenge
        /// Invalid or non-matching password.
        case invalidPassword
        /// Invalid or not-found username.
        case invalidUsername
        /// Two factor authentication with available `Medium`s.
        case twoFactorAuthenticationChallenge(availableMedia: [Medium])
    }

    /// A non-optional `String` containing the logging user's username.
    public let username: String
    /// A non-optional `String` containing the logging user's password.
    public let password: String
    
    /// An optional `Medium` among the vailable ones passed through `status`. Defaults to `nil`.
    /// Setting it to a non-`nil` value attempts to send the `code` to resolve the challenge.
    public var medium: Medium?
    /// An optional `String` containing the authentication challenge code. Defaults to `nil`.
    /// Setting it to a non-`nil` value attempts to resolve the challenge.
    public var code: String?
    
    /// An optional `Result` `enum`holding reference to the current status.
    internal var state: Result<[HTTPCookie], Swift.Error>? {
        didSet {
            guard let state = state else { return }
            onStateChange?(state)
        }
    }
    /// An optional block to be called everytime `state` changes.
    internal var onStateChange: ((Result<[HTTPCookie], Swift.Error>) -> Void)?

    // MARK: Lifecycle
    /// Init a basic autherization model.
    /// - parameter username: A `String` providing a valid user's username.
    /// - parameter password: A `String` providing a valid user's password.
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    // MARK: Authenticator
    /// Authenticate.
    /// - parameter onStateChange: A block called everytime `state` changes.
    public func authenticate(onStateChange: @escaping (Result<[HTTPCookie], Swift.Error>) -> Void) {
        guard state == nil, self.onStateChange == nil else { return onStateChange(.failure(Error.authenticating)) }
        self.onStateChange = onStateChange
        // TODO: perform request.
        
    }
}

