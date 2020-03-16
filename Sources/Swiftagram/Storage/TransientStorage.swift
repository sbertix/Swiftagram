//
//  TransientStorage.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

/// A `struct` holding reference to all transient `Secret`s.
/// - note: Use when only dealing with one-shot `Secret`s.
public struct TransientStorage: Storage {
    /// Init.
    public init() { }

    /// The implementation does nothing.
    /// - returns: `nil`.
    public func find(matching identifier: String) -> Secret? { return nil }

    /// The implementation does nothing.
    /// - returns: An empty `Array`.
    public func all() -> [Secret] { return [] }

    /// The implementation does nothing.
    public func store(_ response: Secret) { }

    /// The implementation does nothing.
    /// - returns: `nil`.
    @discardableResult
    public func remove(matching identifier: String) -> Secret? { return nil }
}
