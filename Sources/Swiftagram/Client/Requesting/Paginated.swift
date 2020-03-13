//
//  Paginated.swift
//  Swiftagra
//
//  Created by Stefano Bertagno on 13/03/2020.
//

import Foundation

/// A `struct` for paginating `Requestable`.
public struct Paginated<Requestable: Swiftagram.Requestable>: Swiftagram.Requestable {
    /// `Response` defaults to `Requestable.Response`.
    public typealias Response = Requestable.Response

    /// A valid `Requestable`.
    internal var requestable: Requestable
    /// The pagination `URLQueryItem` `name`. Defaults to `max_id`.
    public var key: String
    /// The initial value for `URLQueryItem` `value`. Defaults to `nil`.
    public var initial: String?
    /// A block returning the next value for `URLQueryItem` `value`. Return `nil` to stop pagination.
    public var next: (Result<Response, Error>) -> String?

    // MARK: Lifecycle
    /// Init.
    /// - parameters:
    ///     - requestable: A valid `Requestable`.
    ///     - key: The pagination `URLQueryItem` `name`. Defaults to `max_id`.
    ///     - intiail: The initial value for `URLQueryItem` `value`. Defaults to `nil`.
    ///     - next: A block returning the next value for `URLQueryItem` `value`. Return `nil` to stop pagination.
    /// - note: use `requestable.paginating(key:initial:next:)` instead.
    internal init(requestable: Requestable,
                  key: String = "max_id",
                  initial: String? = nil,
                  next: @escaping (Result<Response, Error>) -> String?) {
        self.requestable = requestable
        self.key = key
        self.initial = initial
        self.next = next
    }
}

extension Paginated: Composable where Requestable: Swiftagram.Composable { }
extension Paginated: WrappedComposable where Requestable: Swiftagram.Composable {
    /// A valid `Composable`.
    public var composable: Requestable {
        get { return requestable }
        set { requestable = newValue }
    }

    // MARK: Requests
    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onChange: A block accepting a `DataMappable` and returning the next max id value.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    public func cycleTask(by requester: Requester = .default,
                          onChange: @escaping (Result<Response, Error>) -> Void) -> Requester.Task {
        return Requester.Task(endpoint: requestable.query(key, value: initial),
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = $0.map { Response.process(data: $0.data) }
                                var nextEndpoint: Paginated<Requestable>?
                                if let nextValue = self.next(mapped) {
                                    nextEndpoint = self.query(self.key, value: nextValue)
                                }
                                // Notify completion.
                                onChange(mapped)
                                // Return the new endpoint.
                                return nextEndpoint
        }
    }

    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onChange: A block accepting a `DataMappable` and returning the next max id value.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    public func debugCycleTask(by requester: Requester = .default,
                               onChange: @escaping (Requester.Task.Result<Response>) -> Void) -> Requester.Task {
        return Requester.Task(endpoint: requestable.query(key, value: initial),
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = $0.map { (data: Response.process(data: $0.data), response: $0.response) }
                                var nextEndpoint: Paginated<Requestable>?
                                if let nextValue = self.next(mapped.map { $0.data }) {
                                    nextEndpoint = self.query(self.key, value: nextValue)
                                }
                                // Notify completion.
                                onChange(mapped)
                                // Return the new endpoint.
                                return nextEndpoint
        }
    }
}
