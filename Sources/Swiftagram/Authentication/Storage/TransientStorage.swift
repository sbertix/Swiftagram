//
//  TransientStorage.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

/// A `class` holding reference to all transient `Authentication.Response`s.
/// - note: Use when only dealing with one-shot `Authentication.Response`s.
public final class TransientStorage: Storage {
    /// A `String` identifying the current storage.
    public let reference: String? = "transient"

    /// Init.
    public init() { }

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
