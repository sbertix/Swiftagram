//
//  Storage.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

/// A `protocol` describing a form of `Storage` for `Secret`s.
/// - warning: `Secret`s contain sensitive information: avoid storing them unencrypted.
public protocol Storage {
    /// Find a `Secret` stored in `self`.
    /// - returns: A `Secret` or `nil` if no response could be found.
    /// - note: Prefer `Secret.stored` to access it.
    func find(matching identifier: String) -> Secret?

    /// Return all `Secret`s stored in `self`.
    /// - returns: An `Array` of `Secret`s stored in `self`.
    func all() -> [Secret]

    /// Store a `Secret` in `self`.
    /// - note: Prefer `Secret.store` to access it.
    func store(_ response: Secret)

    /// Delete a `Secret` in `self`.
    /// - returns: The removed `Secret` or `nil` if none was found.
    @discardableResult
    func remove(matching identifier: String) -> Secret?
}
public extension Storage {
    /// Delete all cached `Secret`s.
    func removeAll() { all().map { $0.id }.forEach { remove(matching: $0) }}
}

/// An `Array` of `Storage`s should conform to `Storage`, and all values should be returned.
extension Array: Storage where Element: Storage {
    /// Find the first `Secret` stored in one of the elements.
    /// - returns: A `Secret` or `nil` if no response could be found.
    /// - note: Prefer `Secret.stored` to access it.
    public func find(matching identifier: String) -> Secret? {
        return lazy.compactMap { $0.find(matching: identifier) }.first { _ in true }
    }

    /// Return all `Secret`s stored in all elements.
    /// - returns: An `Array` of `Secret`s stored in `self`.
    public func all() -> [Secret] {
        return map { $0.all() }.reduce(into: []) { $0 += $1 }
    }

    /// Store a `Secret` in all elements.
    /// - note: Prefer `Secret.store` to access it.
    public func store(_ response: Secret) {
        forEach { $0.store(response) }
    }

    /// Delete a `Secret` from all elements, and return the first found.
    /// - returns: The removed `Secret` or `nil` if none was found.
    @discardableResult
    public func remove(matching identifier: String) -> Secret? {
        guard let match = find(matching: identifier) else { return nil }
        forEach { $0.remove(matching: identifier) }
        return match
    }
}
