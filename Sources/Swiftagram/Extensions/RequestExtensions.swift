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
                guard let response = try? response?.get() else { return request }
                return (response[keyPath: keyPath].string() ?? response[keyPath: keyPath].int().flatMap(String.init))
                    .flatMap { request.appending(query: key, with: $0) }
            }
    }

    /// Returns a `Fetcher`.
    /// - returns: A `Fetcher` wrapping `self`.
    func paginating<Mapped: ResponseMappable>(process: Mapped.Type,
                                              key: String = "max_id",
                                              keyPath: KeyPath<Response, Response> = \.nextMaxId,
                                              value: String? = nil) -> Fetcher<Self, Mapped>.Paginated {
        return self.appending(query: key, with: value)
            .prepare(process: Mapped.self) { request, response in
                guard let response = try? response?.get().response() else { return request }
                return (response[keyPath: keyPath].string() ?? response[keyPath: keyPath].int().flatMap(String.init))
                    .flatMap { request.appending(query: key, with: $0) }
            }
    }
}

/// **Instagram** specific accessories for `Requester`.
public extension Requester {
    /// The `URLSessionConfiguration` used for `.instagram`.
    private static let instagramSessionConfiguration: URLSessionConfiguration = {
        let sessionConfiguration = URLSessionConfiguration()
        sessionConfiguration.httpMaximumConnectionsPerHost = 2
        return sessionConfiguration
    }()
    /// An **Instagram** `Requester` matching `.default` with a longer, safer, `waiting` range.
    static let instagram = Requester(configuration: .init(sessionConfiguration: instagramSessionConfiguration,
                                                          dispatcher: .init(),
                                                          waiting: 0.5...1.5))
}
