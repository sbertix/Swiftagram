//
//  Storage.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation
import KeychainSwift

/// A `protocol` describing a form of `Storage` for `Authentication.Response`s.
/// - warning: `Authentication.Response`s contain sensitive information: avoid storing them unencrypted.
public protocol Storage {
    /// Find an `Authentication.Response` stored in `self`.
    /// - returns: A `Response` or `nil` if no response could be found.
    /// - note: Prefer `Authentication.Response.stored` to access it.
    func find(matching identifier: String) -> Authentication.Response?

    /// Return all `Authentication.Response`s stored in `self`.
    /// - returns: An `Array` of `Authentication.Response`s stored in `self`.
    func all() -> [Authentication.Response]

    /// Store an `Authenticated.Response` stored in `self`.
    /// - note: Prefer `Authentication.Response.store` to access it.
    func store(_ response: Authentication.Response)

    @discardableResult
    /// Delete an `Authenticated.Response` in `self`.
    /// - returns: The removed `Authenticated.Response` or `nil` if none was found.
    func remove(matching identifier: String) -> Authentication.Response?
}

#if canImport(KeychainSwift)
/// A `class` holding reference to all `Authentication.Response`s stored in the keychain.
public final class KeychainStorage: Storage {
    /// The shared instance of `Storage`.
    public static let `default` = KeychainStorage()
    /// A `KeychainSwift` used as storage. Defaults to `.init()`.
    private let keychain: KeychainSwift

    // MARK: Lifecycle
    /// Init.
    /// - parameter keychain: A `KeychainSwift`.
    init(keychain: KeychainSwift = .init()) { self.keychain = keychain }

    // MARK: Lookup
    /// Find an `Authentication.Response` stored in the keychain.
    /// - returns: A `Response` or `nil` if no response could be found.
    /// - note: Use `Authentication.Response.stored` to access it.
    public func find(matching identifier: String) -> Authentication.Response? {
        return keychain
            .getData(identifier)
            .flatMap { try? JSONDecoder().decode(Authentication.Response.self, from: $0) }
    }

    /// Return all `Authentication.Response`s stored in the `keychain`.
    /// - returns: An `Array` of `Authentication.Response`s stored in the `keychain`.
    public func all() -> [Authentication.Response] {
        guard let stored = keychain.get("stored") else { return [] }
        return stored.components(separatedBy: ",").compactMap(find)
    }

    // MARK: Locker
    /// Store an `Authenticated.Response` in the keychain.
    /// - note: Prefer `Authentication.Response.store` to access it.
    public func store(_ response: Authentication.Response) {
        // Store.
        guard let data = try? JSONEncoder().encode(response) else { return }
        keychain.set(data, forKey: response.identifier)
        // Update the list of stored respones.
        keychain.set([keychain.get("stored") ?? "", response.identifier].joined(separator: ","),
                     forKey: "stored")
    }

    @discardableResult
    /// Delete an `Authenticated.Response` in the keychain.
    /// - returns: The removed `Authenticated.Response` or `nil` if none was found.
    public func remove(matching identifier: String) -> Authentication.Response? {
        guard let response = find(matching: identifier) else { return nil }
        // Remove the response and update the list.
        keychain.delete(identifier)
        keychain.set((keychain.get("stored") ?? "")
            .components(separatedBy: ",")
            .filter { $0 != identifier }
            .joined(separator: ","),
                     forKey: "stored")
        // Return the response.
        return response
    }
}
#endif

/// A `struct` holding reference to all transient `Authentication.Response`s.
/// - note: Use when only dealing with one-shot `Authentication.Response`s.
public struct TransientStorage: Storage {
    /// The implementation does nothing.
    /// - returns: `nil`.
    public func find(matching identifier: String) -> Authentication.Response? { return nil }

    /// The implementation does nothing.
    /// - returns: An empty `Array`.
    public func all() -> [Authentication.Response] { return [] }

    /// The implementation does nothing.
    public func store(_ response: Authentication.Response) { }

    @discardableResult
    /// The implementation does nothing.
    /// - returns: `nil`.
    public func remove(matching identifier: String) -> Authentication.Response? { return nil }
}
