//
//  Locked.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 13/03/2020.
//

import Foundation

/// A `struct` locking a `Composable` until a `Secret` is passed to it.
public struct Locked<Composable: Swiftagram.Composable>: WrappedComposable {
    /// A valid `Composable`.
    public var composable: Composable

    /// Init.
    /// - parameter composable: A valid `Composable`.
    /// - note: use `composable.locked()` instead.
    internal init(composable: Composable) { self.composable = composable }

    // MARK: Resolve
    /// Unlock the underlying `Composable`.
    /// - parameter secret: A valid `Secret`.
    public func authenticating(with secret: Secret) -> Composable {
        return copy(composable) { $0 = $0.header(secret.headerFields) }
    }
}
