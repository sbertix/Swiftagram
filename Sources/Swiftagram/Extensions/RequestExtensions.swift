//
//  RequestExtensions.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 05/04/2020.
//

import Foundation

import ComposableRequest

/// **Instagram** specific pagination.
public extension Requestable where Self: QueryComposable & QueryParsable {
    /// Returns a `Fetcher`.
    /// - returns: A `Fetcher` wrapping `self`.
    func paginating(key: String = "max_id",
                    keyPath: KeyPath<Response, Response> = \.nextMaxId,
                    value: String? = nil) -> Fetcher<Self, Response>.Paginated {
        return self.appending(query: key, with: value)
            .prepare { request, response in
                guard let response = response else { return request }
                return try? response.get()[keyPath: keyPath].string().flatMap { request.appending(query: key, with: $0) }
        }
    }
}

/// **Instagram** specific accessories for `Requester`.
public extension Requester {
    /// An **Instagram** `Requester` matching `.default` with a longer, safer, `waiting` range.
    static let instagram = Requester(configuration: .init(sessionConfiguration: .default,
                                                          dispatcher: .init(),
                                                          waiting: 0.5...1.5))
}
