//
//  Authenticator.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

import ComposableRequest

/// A `protocol` defining a way to fetch and store `Secret`s.
public protocol Authenticator {
    /// A `Storage` concrete type in which `Secret` are stored.
    associatedtype Storage: ComposableRequest.Storage
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

public extension Requester {
    /// An ephemeral `Requester` guaranteed to be fired immediately, provided as a convinience for custom `Authenticator`s.
    ///
    /// - warning: **Do not** use this to call your `Endpoint`s as Instagram spam filter will surely intervene after just a few call.
    static let authentication = Requester(configuration: .init(sessionConfiguration: .default,
                                                               dispatcher: .init(),
                                                               waiting: 0...0))
}
