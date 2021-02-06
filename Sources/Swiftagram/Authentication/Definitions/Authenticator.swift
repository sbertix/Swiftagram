//
//  Authenticator.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

import ComposableRequest
import ComposableStorage

/// A `protocol` defining a way to fetch and store `Secret`s.
public protocol Authenticator {
    /// A `Storage` concrete type in which `Secret` are stored.
    associatedtype Storage: ComposableStorage.Storage
    /// An `Error` concrete type.
    associatedtype Error: Swift.Error

    /// A `Storage` instance used to store `Secret`s.
    var storage: Storage { get }
    /// A `Client` instance used to create the `Secret`s.
    var client: Client { get }

    /// Return a `Secret` and store it in `storage`.
    ///
    /// - parameter onChange: A block providing a `Result<Secret, Error>`.
    /// - warning: Always call `Secret.store` with `storage` when receiving the `Secret` .
    /// - note: Using `TransientStorage` as `Storage` allows to disregard any storing mechanism.
    func authenticate(_ onChange: @escaping (Result<Secret, Error>) -> Void)
}
