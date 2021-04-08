//
//  Endpoint+Stories.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/04/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `struct` defining stories-related endpoints.
    struct Stories { }
}

public extension Endpoint {
    /// A wrapper for stories-specific endpoints.
    static let stories: Endpoint.Group.Stories = .init()

    /// An endpoint for loading specific endpoints.
    ///
    /// - parameter identifiers: A collection of `String`s.
    /// - returns: A valid `Endpoint.Single`.
    static func stories<C: Collection>(_ identifiers: C) -> Endpoint.Single<TrayItem.Dictionary, Error> where C.Element == String {
        users(identifiers).stories
    }
}
