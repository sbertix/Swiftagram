//
//  Storage.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

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

    /// Store an `Authenticated.Response` in `self`.
    /// - note: Prefer `Authentication.Response.store` to access it.
    func store(_ response: Authentication.Response)

    @discardableResult
    /// Delete an `Authenticated.Response` in `self`.
    /// - returns: The removed `Authenticated.Response` or `nil` if none was found.
    func remove(matching identifier: String) -> Authentication.Response?
}

/// An `Array` of `Storage`s should conform to `Storage`, and all values should be returned.
extension Array: Storage where Element: Storage {
    /// Find the first `Authentication.Response` stored in one of the elements.
    /// - returns: A `Response` or `nil` if no response could be found.
    /// - note: Prefer `Authentication.Response.stored` to access it.
    public func find(matching identifier: String) -> Authentication.Response? {
        return lazy.compactMap { $0.find(matching: identifier) }.first { _ in true }
    }

    /// Return all `Authentication.Response`s stored in all elements.
    /// - returns: An `Array` of `Authentication.Response`s stored in `self`.
    public func all() -> [Authentication.Response] {
        return map { $0.all() }.reduce(into: []) { $0 += $1 }
    }

    /// Store an `Authenticated.Response` in all elements.
    /// - note: Prefer `Authentication.Response.store` to access it.
    public func store(_ response: Authentication.Response) {
        forEach { $0.store(response) }
    }

    @discardableResult
    /// Delete an `Authenticated.Response` from all elements, and return the first found.
    /// - returns: The removed `Authenticated.Response` or `nil` if none was found.
    public func remove(matching identifier: String) -> Authentication.Response? {
        guard let match = find(matching: identifier) else { return nil }
        forEach { $0.remove(matching: identifier) }
        return match
    }
}
