//
//  UserDefaultsStorage.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

/// A `struct` holding reference to all `Secret`s stored in the `UserDefaults`.
/// - warning: `UserDefaults` are not safe for storing `Secret`s. **DO NOT USE THIS IN PRODUCTION**.
/// - note: `
///     KeychainStorage` is the encoded and ready-to-use alternative to `UserDefaultsStorage`.
///     Add https://github.com/evgenyneu/keychain-swift to your dependencies and import it to start using it.
public struct UserDefaultsStorage: Storage {
    /// A `UserDefaults` used as storage. Defaults to `.standard`.
    private let userDefaults: UserDefaults

    // MARK: Lifecycle
    /// Init.
    /// - parameter userDefaults: A `UserDefaults`.
    public init(userDefaults: UserDefaults = .standard) { self.userDefaults = userDefaults }

    // MARK: Lookup
    /// Find a `Secret` stored in the user defaults.
    /// - returns: A `Secret` or `nil` if no response could be found.
    /// - note: Use `Secret.stored` to access it.
    public func find(matching identifier: String) -> Secret? {
        return userDefaults
            .data(forKey: identifier)
            .flatMap { try? JSONDecoder().decode(Secret.self, from: $0) }
    }

    /// Return all `Secret`s stored in the  user defaults.
    /// - returns: An `Array` of `Secret`s stored in the `userDefaults`.
    public func all() -> [Secret] {
        guard let stored = userDefaults.string(forKey: "swiftagram-stored") else { return [] }
        return Set(stored.components(separatedBy: ",")).compactMap(find)
    }

    // MARK: Locker
    /// Store a `Secret` in the user defaults.
    /// - note: Prefer `Secret.store` to access it.
    public func store(_ response: Secret) {
        // Store.
        guard let data = try? JSONEncoder().encode(response) else { return }
        userDefaults.set(data, forKey: response.id)
        // Update the list of stored respones.
        var stored = Set(userDefaults.string(forKey: "swiftagram-stored")?.components(separatedBy: ",") ?? [])
        stored.insert(response.id)
        userDefaults.set(stored.joined(separator: ","), forKey: "swiftagram-stored")
    }

    @discardableResult
    /// Delete a `Secret` in the user defaults.
    /// - returns: The removed `Secret` or `nil` if none was found.
    public func remove(matching identifier: String) -> Secret? {
        guard let response = find(matching: identifier) else { return nil }
        // Remove the response and update the list.
        userDefaults.removeObject(forKey: identifier)
        userDefaults.set((userDefaults.string(forKey: "swiftagram-stored") ?? "")
            .components(separatedBy: ",")
            .filter { $0 != identifier }
            .joined(separator: ","),
                         forKey: "swiftagram-stored")
        // Return the response.
        return response
    }
}
