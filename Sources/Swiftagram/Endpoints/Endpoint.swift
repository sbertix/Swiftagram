//
//  Endpoint.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

/// A module-like `enum` defining all possible `Endpoint`s.
public enum Endpoint {
    /// An `Endpoint` allowing for a paginated request with a custom `Response` value.
    ///
    /// - note: Always reference this alias, to abstract away `ComposableRequest` implementation.
    public typealias Paginated < Response,
                               Offset,
                               Failure: Error> = LockSessionPagerProvider < Secret,
                                                                          Offset,
                                                                          AnyPublisher<Response, Failure>>

    /// An `Endpoint` allowing for a single request with a custom `Response` value.
    ///
    /// - note: Always reference this alias, to abstract away `ComposableRequest` implementation.
    public typealias Single < Response,
                            Failure: Error> = LockSessionProvider < Secret,
                                                                  AnyPublisher<Response, Failure>>

    /// A module-like `enum` to hide away endpoint wrappers definitions.
    public enum Group { }
}

public extension Request {
    /// An `Endpoint` pointing to `i.instagram.com`.
    static let api: Request = .init("https://i.instagram.com")

    /// An `Endpoint` pointing to `api/v1`.
    static let version1: Request = api.path(appending: "/api/v1")

    /// An `Endpoint` pointing to the Instagram homepage.
    static let generic: Request = .init("https://www.instagram.com")
}
