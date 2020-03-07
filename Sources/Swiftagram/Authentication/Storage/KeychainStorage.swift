//
//  KeychainStorage.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

#if canImport(KeychainSwift)
import Foundation
import KeychainSwift

/// A `class` holding reference to all `Authentication.Response`s stored in the keychain.
public final class KeychainStorage: Storage {
    /// The shared instance of `Storage`.
    public static let `default` = KeychainStorage()
    /// A `KeychainSwift` used as storage. Defaults to `.init()`.
    private let keychain: KeychainSwift
    /// A `String` holding reference to the current storage.
    public let reference: String? = "keychain"

    // MARK: Lifecycle
    /// Init.
    /// - parameter keychain: A `KeychainSwift`.
    public init(keychain: KeychainSwift = .init()) { self.keychain = keychain }

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
        guard let stored = keychain.get(reference.flatMap { $0+"-stored" } ?? "stored") else { return [] }
        return Set(stored.components(separatedBy: ",")).compactMap(find)
    }

    // MARK: Locker
    /// Store an `Authenticated.Response` in the keychain.
    /// - note: Prefer `Authentication.Response.store` to access it.
    public func store(_ response: Authentication.Response) {
        // Store.
        guard let data = try? JSONEncoder().encode(response) else { return }
        keychain.set(data, forKey: response.id)
        // Update the list of stored respones.
        var stored = Set(keychain.get(reference.flatMap { $0+"-stored" } ?? "stored")?.components(separatedBy: ",") ?? [])
        stored.insert(response.id)
        keychain.set(stored.joined(separator: ","), forKey: reference.flatMap { $0+"-stored" } ?? "stored")
    }

    @discardableResult
    /// Delete an `Authenticated.Response` in the keychain.
    /// - returns: The removed `Authenticated.Response` or `nil` if none was found.
    public func remove(matching identifier: String) -> Authentication.Response? {
        guard let response = find(matching: identifier) else { return nil }
        // Remove the response and update the list.
        keychain.delete(identifier)
        keychain.set((keychain.get(reference.flatMap { $0+"-stored" } ?? "stored") ?? "")
            .components(separatedBy: ",")
            .filter { $0 != identifier }
            .joined(separator: ","),
                     forKey: reference.flatMap { $0+"-stored" } ?? "stored")
        // Return the response.
        return response
    }
}
#endif
