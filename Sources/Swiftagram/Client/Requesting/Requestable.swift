//
//  Requestable.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 13/03/2020.
//

import Foundation

/// A `protocol` defining a generic `URLRequest` with an associated response type.
public protocol Requestable {
    /// The `Response` to be expected.
    associatedtype Response: DataMappable
}

// MARK: Accessories
public extension Requestable {
    /// Change the `Response` type to `response`.
    /// - parameter response: A valid `Response` type.
    /// - returns: A new `Expectation` from `self`..
    func expecting<Response: DataMappable>(_ response: Response.Type) -> Expectation<Self, Response> {
        return .init(requestable: self)
    }

    /// Paginate the request.
    /// - parameters:
    ///     - key: The pagination `URLQueryItem` `name`. Defaults to `max_id`.
    ///     - intiail: The initial value for `URLQueryItem` `value`. Defaults to `nil`.
    ///     - next: A block returning the next value for `URLQueryItem` `value`. Return `nil` to stop pagination.
    /// - returns: A new `Paginated` item from `self`.
    func paginating(key: String = "max_id",
                    initial: String? = nil,
                    next: @escaping (Result<Response, Error>) -> String?) -> Paginated<Self> {
        return .init(requestable: self, key: key, initial: initial, next: next)
    }
}

public extension Requestable where Response == Swiftagram.Response {
    /// Paginate the request.
    /// - parameters:
    ///     - key: The pagination `URLQueryItem` `name`. Defaults to `max_id`.
    ///     - intiail: The initial value for `URLQueryItem` `value`. Defaults to `nil`.
    ///     - next: A block returning the next value for `URLQueryItem` `value`. Return `nil` to stop pagination. Defaults to `.nextMaxId`.
    /// - returns: A new `Paginated` item from `self`.
    func paginating(key: String = "max_id",
                    initial: String? = nil,
                    next: @escaping (Result<Response, Error>) -> String? = { try? $0.get().nextMaxId.string() }) -> Paginated<Self> {
        return .init(requestable: self, key: key, initial: initial, next: next)
    }
}

// MARK: Requests
public extension Requestable where Self: Composable {
    /// Prepare the `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onComplete: A block accepting a `DataMappable`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func task(by requester: Requester = .default,
              onComplete: @escaping (Result<Response, Error>) -> Void) -> Requester.Task {
        return Requester.Task(endpoint: self, requester: requester) {
            onComplete($0.map { Response.process(data: $0.data) })
            return nil
        }
    }

    /// Prepare the `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onComplete: A block accepting a `DataMappable`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func debugTask(by requester: Requester = .default,
                   onComplete: @escaping (Requester.Task.Result<Response>) -> Void) -> Requester.Task {
        return Requester.Task(endpoint: self,
                              requester: requester) {
                                onComplete($0.map { (Response.process(data: $0.data), $0.response) })
                                return nil
        }
    }
}
