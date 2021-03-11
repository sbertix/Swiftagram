//
//  Endpoint.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

import ComposableRequest

/// A module-like `enum` defining all possible `Endpoint`s.
public enum Endpoint {
    /// An `Endpoint` allowing for a paginated request with a custom `Response` value.
    ///
    /// - note: Always reference this alias, to abstract away `ComposableRequest` implementation.
    public typealias Paginated<Response,
                               Offset,
                               Failure: Error> = LockSessionPagerProvider<Secret,
                                                                          Offset,
                                                                          UnlockedDisposable<Response, Failure>>

    /// An `Endpoint` allowing for a single request with a custom `Response` value.
    ///
    /// - note: Always reference this alias, to abstract away `ComposableRequest` implementation.
    public typealias Disposable<Response,
                                Failure: Error> = LockSessionProvider<Secret,
                                                                      UnlockedDisposable<Response, Failure>>

    /// An `Endpoint` allowing for a single request with a custom `Response` value.
    ///
    /// - note: Always reference this alias, to abstract away `ComposableRequest` implementation.
    public typealias UnlockedDisposable<Response, Failure: Error> = AnyPublisher<Response, Failure>

    // MARK: Composition

    /// An `Endpoint` pointing to `i.instagram.com`.
    public static let api: Request = .init("https://i.instagram.com")

    /// An `Endpoint` pointing to `api/v1`.
    public static let version1: Request = api.path(appending: "/api/v1")

    /// An `Endpoint` pointing to the Instagram homepage.
    public static var generic: Request = .init("https://www.instagram.com")
}
