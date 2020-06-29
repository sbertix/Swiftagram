//
//  EndpointExplore.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A `struct` holding reference to `discover` `Endpoint`s. Requires authentication.
    struct Discover {
        /// The base endpoint.
        private static let base = Endpoint.version1.discover.appendingDefaultHeader()

        /// The explore feed.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func explore(startingAt page: String? = nil) -> ResponsePaginated {
            return base.explore.paginating(value: page).locking(Secret.self)
        }
    }
}
