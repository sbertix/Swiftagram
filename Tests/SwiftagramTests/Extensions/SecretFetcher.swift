//
//  SecretFetcher.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 28/10/20.
//

import Foundation

import Swiftagram
import SwiftagramCrypto

/// The `SecretFetcher`.
///
/// This is stored here in order to bypass `XCTestCase` `init` limitation.
private let defaultSecretFetcher = SecretFetcher()

/// A fallback counter.
///
/// This is stored here in order to bypass `XCTestCase` `init` limitation.
private var counter = 0

/// A `class` logging in once and caching the `Secret` for future use.
final class SecretFetcher {
    /// The shared instance of `Self`.
    static var `default`: SecretFetcher { return defaultSecretFetcher }

    /// The username.
    let username: String
    /// The password.
    let password: String

    /// A lock.
    private let lock = NSLock()
    /// The underlying secret. Do not call this directly.
    private var cachedSecret: Result<Secret, Error>?

    /// Init.
    fileprivate init() {
        self.username = ProcessInfo.processInfo.environment["IG_USERNAME"]!
        self.password = ProcessInfo.processInfo.environment["IG_PASSWORD"]!
    }

    /// Fetch the secret.
    ///
    /// - parameter onComplete: A valid completion handler.
    func secret(_ onComplete: @escaping (Result<Secret, Error>) -> Void) {
        lock.lock()
        // Check for the existence of a secret.
        counter += 1
        if let secret = cachedSecret { onComplete(secret); lock.unlock(); return }
        guard counter == 1 else { fatalError("You should not be able to attempt authenticating more than once.") }
        // Fetch one.
        BasicAuthenticator(username: username, password: password)
            .authenticate { [self] in
                self.cachedSecret = $0
                onComplete($0)
                lock.unlock()
            }
    }
}
