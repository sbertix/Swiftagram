//
//  Endpoint.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import ComposableRequest
import Foundation

/// A `struct` defining all possible `Endpoint`s.
public struct Endpoint {
    // MARK: Aliases
    /// An `Endpoint` allowing for pagination.
    /// - note: Always reference this alias, to abstract away `ComposableRequest` implementation.
    public typealias ResponsePaginated = Locker<Fetcher<Request, Response>.Paginated, Secret>
    /// An `Endpoint` allowing for a single request with a custom `Response` value.
    /// - note: Always reference this alias, to abstract away `ComposableRequest` implementation.
    public typealias Disposable<Response> = Locker<Fetcher<Request, Response>.Disposable, Secret>
    /// An `Endpoint` allowing for a single request.
    /// - note: Always reference this alias, to abstract away `ComposableRequest` implementation.
    public typealias ResponseDisposable = Locker<Fetcher<Request, Response>.Disposable, Secret>

    // MARK: Composition
    /// An `Endpoint` pointing to `api/v1`.
    public static let version1: Request = .init("https://i.instagram.com/api/v1")
    /// An `Endpoint` pointing to the Instagram homepage.
    public static var generic: Request = .init("https://www.instagram.com")
}
