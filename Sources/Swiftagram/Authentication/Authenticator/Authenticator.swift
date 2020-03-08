//
//  Authenticator.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

/// A `protocol` describing a form of fetching `Secret`s.
public protocol Authenticator {
    /// A `Storage` concrete type in which `Secret` are stored.
    associatedtype Storage: Swiftagram.Storage
    /// A `Storage` instance used to store `Secret`s.
    var storage: Storage { get }

    /// Return a `Secret` and store it in `storage`.
    /// - parameter onChange: A block providing a `Result<Secret, Error>`.
    /// - warning: Always call `Secret.store` with `storage` when receiving the `Secret` .
    /// - note: Using `TransientStorage` as `Storage` allows to disregard any storing mechanism.
    func authenticate(_ onChange: @escaping (Result<Secret, Error>) -> Void)
}
