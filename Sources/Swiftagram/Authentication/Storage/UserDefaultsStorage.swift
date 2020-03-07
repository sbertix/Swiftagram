//
//  UserDefaultsStorage.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

/// A `class` holding reference to all `Authentication.Response`s stored in the `UserDefaults`.
/// - warning: `UserDefaults` are not safe for storing `Authentication.Response`s. **DO NOT USE THIS IN PRODUCTION**.
public final class UserDefaultsStorage: Storage {
    /// The shared instance of `Storage`.
    public static let `default` = UserDefaultsStorage()
    /// A `UserDefaults` used as storage. Defaults to `.standard`.
    private let userDefaults: UserDefaults
    /// A `String` holding reference to the current storage.
    public let reference: String? = "userdefaults"

    // MARK: Lifecycle
    /// Init.
    /// - parameter userDefaults: A `UserDefaults`.
    public init(userDefaults: UserDefaults = .standard) { self.userDefaults = userDefaults }

    // MARK: Lookup
    /// Find an `Authentication.Response` stored in the user defaults.
    /// - returns: A `Response` or `nil` if no response could be found.
    /// - note: Use `Authentication.Response.stored` to access it.
    public func find(matching identifier: String) -> Authentication.Response? {
        return userDefaults
            .data(forKey: identifier)
            .flatMap { try? JSONDecoder().decode(Authentication.Response.self, from: $0) }
    }

    /// Return all `Authentication.Response`s stored in the  user defaults.
    /// - returns: An `Array` of `Authentication.Response`s stored in the `userDefaults`.
    public func all() -> [Authentication.Response] {
        guard let stored = userDefaults.string(forKey: reference.flatMap { $0+"-stored" } ?? "stored") else { return [] }
        return Set(stored.components(separatedBy: ",")).compactMap(find)
    }

    // MARK: Locker
    /// Store an `Authenticated.Response` in the user defaults.
    /// - note: Prefer `Authentication.Response.store` to access it.
    public func store(_ response: Authentication.Response) {
        // Store.
        guard let data = try? JSONEncoder().encode(response) else { return }
        userDefaults.set(data, forKey: response.id)
        // Update the list of stored respones.
        var stored = Set(userDefaults.string(forKey: reference.flatMap { $0+"-stored" } ?? "stored")?.components(separatedBy: ",") ?? [])
        stored.insert(response.id)
        userDefaults.set(stored.joined(separator: ","), forKey: reference.flatMap { $0+"-stored" } ?? "stored")
    }

    @discardableResult
    /// Delete an `Authenticated.Response` in the user defaults.
    /// - returns: The removed `Authenticated.Response` or `nil` if none was found.
    public func remove(matching identifier: String) -> Authentication.Response? {
        guard let response = find(matching: identifier) else { return nil }
        // Remove the response and update the list.
        userDefaults.removeObject(forKey: identifier)
        userDefaults.set((userDefaults.string(forKey: reference.flatMap { $0+"-stored" } ?? "stored") ?? "")
            .components(separatedBy: ",")
            .filter { $0 != identifier }
            .joined(separator: ","),
                         forKey: reference.flatMap { $0+"-stored" } ?? "stored")
        // Return the response.
        return response
    }
}
