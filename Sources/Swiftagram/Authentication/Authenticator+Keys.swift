//
//  Authenticator+Keys.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 10/04/21.
//

import Foundation

import ComposableStorage

public extension Authenticator {
    /// A `class` defining an instance used for `Secret`s management.
    final class Keys {
        /// The authenticator.
        private let authenticator: Authenticator
        /// `Secret`s labels. `nil` means all secrets should be managed.
        public let labels: [String]?

        /// Init.
        ///
        /// - parameters:
        ///     - authenticator: A valid `Authenticator`.
        ///     - labels: An optional array of `String`s.
        fileprivate init(authenticator: Authenticator,
                         labels: [String]?) {
            self.authenticator = authenticator
            self.labels = labels
        }
    }

    /// Return a manager for all `Secret`s.
    var secrets: Keys {
        .init(authenticator: self, labels: nil)
    }

    /// Return some specific `Secret`s manager.
    ///
    /// - parameter labels: A collection of `String`s.
    /// - returns: Some valid `Keys`.
    func secrets<C: Collection>(_ labels: C) -> Keys where C.Element == String {
        .init(authenticator: self, labels: Array(labels))
    }

    /// Return some specific `Secret`s manager.
    ///
    /// - parameter secrets: A collection of `Secret`s.
    /// - returns: Some valid `Keys`.
    func secrets<C: Collection>(_ secrets: C) -> Keys where C.Element == Secret {
        .init(authenticator: self, labels: secrets.map(\.label))
    }
}

public extension Authenticator.Keys {
    /// Try fetching `Secret`s matching `label`s.
    ///
    /// - throws: Some `Error`.
    /// - returns: An array of `Secret`s.
    func get() throws -> [Secret] {
        switch labels {
        case let labels?:
            return try AnyStorage.items(in: authenticator.storage)
                .filter { labels.contains($0.label) }
        default:
            return try AnyStorage.items(in: authenticator.storage)
        }
    }

    /// Delete selected `Secret`s.
    ///
    /// - throws: Some `Error`.
    /// - returns: An optional `Secret`.
    @discardableResult
    func delete() throws -> [Secret] {
        switch labels {
        case let labels?:
            return try labels.compactMap { try authenticator.secret($0).delete() }
        default:
            return try authenticator.secrets.get().compactMap { try authenticator.secret($0).delete() }
        }
    }
}
