//
//  Requestable.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 05/04/2020.
//

import Foundation

import ComposableRequest

public extension Requestable where Self: QueryComposable & QueryParsable {
    /// Returns a `Fetcher`.
    ///
    /// - parameters:
    ///     - key: A valid `String`.
    ///     - keyPath: A valid `Wrapper` transformer.
    ///     - value: An optional `String`, as the initial value.
    /// - returns: A `Fetcher` wrapping `self`.
    func paginating(key: String = "max_id",
                    keyPath: @escaping (Wrapper) -> Wrapper = \.nextMaxId,
                    value: String? = nil) -> Fetcher<Self, Wrapper>.Paginated {
        self.appending(query: key, with: value)
            .prepare { request, response in
                guard let response = try? response?.get() else { return request }
                return (keyPath(response).string() ?? keyPath(response).int().flatMap(String.init))
                    .flatMap { request.appending(query: key, with: $0) }
            }
    }

    /// Returns a `Fetcher`.
    ///
    /// - parameters:
    ///     - key: A valid `String`.
    ///     - keyPath: A valid `Wrapper` transformer.
    ///     - value: An optional `String`, as the initial value.
    /// - returns: A `Fetcher` wrapping `self`.
    func paginating<Mapped: Wrapped>(process: Mapped.Type,
                                     key: String = "max_id",
                                     keyPath: @escaping (Wrapper) -> Wrapper = \.nextMaxId,
                                     value: String? = nil) -> Fetcher<Self, Mapped>.Paginated {
        self.appending(query: key, with: value)
            .prepare(process: Mapped.self) { request, response in
                guard let response = try? response?.get().wrapper() else { return request }
                return (keyPath(response).string() ?? keyPath(response).int().flatMap(String.init))
                    .flatMap { request.appending(query: key, with: $0) }
            }
    }
}
