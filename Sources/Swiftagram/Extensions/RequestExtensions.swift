//
//  RequestExtensions.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 05/04/2020.
//

import Foundation

import ComposableRequest

/// **Instagram** specific pagination.
public extension Requestable where Self: QueryComposable {
    /// Returns a `Fetcher`.
    /// - returns: A `Fetcher` wrapping `self`.
    func paginating(key: String = "max_id",
                    keyPath: KeyPath<Response, Response> = \.nextMaxId) -> Fetcher<Self, Response>.Paginated {
        return self.prepare { request, result in
            request.appending(query: key, with: result.flatMap { try? $0.get()[keyPath: keyPath].string() })
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
