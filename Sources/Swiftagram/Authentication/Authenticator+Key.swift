//
//  Authenticator+Key.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 10/04/21.
//

import Foundation

import ComposableStorage

public extension Authenticator {
    /// A `class` defining an instance used for `Secret` management.
    final class Key {
        /// The authenticator.
        private let authenticator: Authenticator
        /// The `Secret` label.
        public let label: String

        /// Init.
        ///
        /// - parameters:
        ///     - authenticator: A valid `Authenticator`.
        ///     - label: A valid `String`.
        fileprivate init(authenticator: Authenticator,
                         label: String) {
            self.authenticator = authenticator
            self.label = label
        }
    }

    /// Return a specific `Secret` manager.
    ///
    /// - parameter label: A valid `String`.
    /// - returns: A valid `Key`.
    func secret(_ label: String) -> Key {
        .init(authenticator: self, label: label)
    }

    /// Return a specific `Secret` manager.
    ///
    /// - parameter secret: A valid `Secret`.
    /// - returns: A valid `Key`.
    func secret(_ secret: Secret) -> Key {
        self.secret(secret.label)
    }
}

public extension Authenticator.Key {
    /// Try fetching a `Secret` matching the given `label`.
    ///
    /// - throws: Some `Error`.
    /// - returns: An optional `Secret`.
    func get() throws -> Secret? {
        try AnyStorage.item(matching: label, in: authenticator.storage)
    }

    /// Delete the selected `Secret`.
    ///
    /// - throws: Some `Error`.
    /// - returns: An optional `Secret`.
    @discardableResult
    func delete() throws -> Secret? {
        try AnyStorage.discard(label, in: authenticator.storage)
    }
}
