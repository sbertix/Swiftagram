//
//  Paginated.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

/// A `struct` for changing expected `Paginatable`s.
public struct Paginated<Originating: Singular, Response: DataMappable>: Paginatable {
    /// The associated expectation.
    public var paginatable: Originating

    /// The `name` of the `URLQueryItem` used for paginating.
    public var key: String
    /// The inital `value` of the `URLQueryItem` used for paginating.
    public var initial: String?
    /// The next `value` of the `URLQueryItem` user for paginating, based on the last `Response`.
    public var next: (Result<Response, Error>) -> String?
}

/// Conditional conformacies to `Lockable`.
extension Paginated: Lockable where Originating: Lockable {
    /// Update as the `Unlockable` was unloacked.
    /// - parameters:
    ///     - unlockable: A valid `Unlockable`.
    ///     - secret:  A valid `Secret`.
    /// - warning: Do not call directly.
    public static func unlock(_ unlockable: Swiftagram.Locked<Paginated<Originating, Response>>,
                              with secret: Secret) -> Paginated<Originating, Response> {
        return copy(unlockable.lockable) { $0.paginatable = Originating.unlock($0.paginatable.locked(), with: secret) }
    }
}

/// Conditional conformacies to `Unlockable`.
extension Paginated: Unlockable where Originating: Unlockable, Originating.Locked: Singular {
    /// The associated `Lockable`.
    public typealias Locked = Paginated<Originating.Locked, Response>

    /// Unlock the underlying `Locked`.
    /// - parameter secret: A valid `Secret`.
    public func authenticating(with secret: Secret) -> Locked {
        return .init(paginatable: paginatable.authenticating(with: secret),
                     key: key,
                     initial: initial,
                     next: next)
    }
}

/// Conditional conformacies to `Composable`.
extension Paginated: Composable where Originating: Composable { }
extension Paginated: WrappedComposable where Originating: Composable {
    /// A valid `Composable`.
    public var composable: Originating {
        get { return paginatable }
        set { paginatable = newValue }
    }
}

/// Conditional conformacies to `Requestable`.
extension Paginated: Requestable where Originating: Requestable {
    /// Compute the `URLRequest`.
    /// - returns: An optional `URLRequest`.
    public func request() -> URLRequest? { return paginatable.request() }
}
