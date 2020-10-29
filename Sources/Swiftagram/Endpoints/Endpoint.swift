//
//  Endpoint.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import ComposableRequest
import Foundation

/// A module-like `enum` defining all possible `Endpoint`s.
public enum Endpoint {
    /// An `Endpoint` allowing for a paginated request with a custom `Response` value.
    ///
    /// - note: Always reference this alias, to abstract away `ComposableRequest` implementation.
    public typealias Paginated<Response> = Locker<Fetcher<Request, Response>.Paginated, Secret>

    /// An `Endpoint` allowing for a single request with a custom `Response` value.
    ///
    /// - note: Always reference this alias, to abstract away `ComposableRequest` implementation.
    public typealias Disposable<Response> = Locker<Fetcher<Request, Response>.Disposable, Secret>

    // MARK: Composition

    /// An `Endpoint` pointing to `i.instagram.com`.
    public static let api: Request = .init("https://i.instagram.com")

    /// An `Endpoint` pointing to `api/v1`.
    public static let version1: Request = api.appending(path: "/api/v1")

    /// An `Endpoint` pointing to the Instagram homepage.
    public static var generic: Request = .init("https://www.instagram.com")
}
