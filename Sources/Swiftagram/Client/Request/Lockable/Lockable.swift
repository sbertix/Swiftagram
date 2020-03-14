//
//  Lockable.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

/// A `protocol` defining an element requiring a `Secret` to be resolved.
public protocol Lockable {
    /// Update as the `Unlockable` was unloacked.
    /// - parameters:
    ///     - unlockable: A valid `Unlockable`.
    ///     - secret:  A valid `Secret`.
    /// - warning: Do not call directly.
    static func unlock(_ unlockable: Locked<Self>, with secret: Secret) -> Self
}

/// Default extensions for `Lockable`.
public extension Lockable {
    /// Lock `self` until a `Secret` is used for authenticating the request.
    /// - returns: A `Locked<Self>` value wrapping `self`.
    func locked() -> Locked<Self> { return .init(lockable: self) }
}

/// A `protocol` defining an element allowing for authentication.
public protocol Unlockable {
    /// The associated `Lockable`.
    associatedtype Locked: Lockable

    /// Unlock the underlying `Locked`.
    /// - parameter secret: A valid `Secret`.
    func authenticating(with secret: Secret) -> Locked
}
