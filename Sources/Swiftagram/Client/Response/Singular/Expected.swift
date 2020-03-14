//
//  Expected.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

/// A `struct` for changing the expected `Response`.
public struct Expected<Expecting: Swiftagram.Singular, Response: DataMappable>: Swiftagram.Singular {
    /// The associated expectation.
    public var expecting: Expecting
}

/// Conditional conformacies to `Lockable`.
extension Expected: Lockable where Expecting: Lockable {
    /// Update as the `Unlockable` was unloacked.
    /// - parameters:
    ///     - unlockable: A valid `Unlockable`.
    ///     - secret:  A valid `Secret`.
    /// - warning: Do not call directly.
    public static func unlock(_ unlockable: Swiftagram.Locked<Expected<Expecting, Response>>,
                              with secret: Secret) -> Expected<Expecting, Response> {
        return copy(unlockable.lockable) { $0.expecting = Expecting.unlock($0.expecting.locked(), with: secret) }
    }
}

/// Conditional conformacies to `Unlockable`.
extension Expected: Unlockable where Expecting: Unlockable, Expecting.Locked: Swiftagram.Singular {
    /// The associated `Lockable`.
    public typealias Locked = Expected<Expecting.Locked, Response>

    /// Unlock the underlying `Locked`.
    /// - parameter secret: A valid `Secret`.
    public func authenticating(with secret: Secret) -> Locked {
        return .init(expecting: expecting.authenticating(with: secret))
    }
}

/// Conditional conformacies to `Composable`.
extension Expected: Composable where Expecting: Composable { }
extension Expected: WrappedComposable where Expecting: Composable {
    /// A valid `Composable`.
    public var composable: Expecting {
        get { return expecting }
        set { expecting = newValue }
    }
}

/// Conditional conformacies to `Requestable`.
extension Expected: Requestable where Expecting: Requestable {
    /// Compute the `URLRequest`.
    /// - returns: An optional `URLRequest`.
    public func request() -> URLRequest? { return expecting.request() }
}
