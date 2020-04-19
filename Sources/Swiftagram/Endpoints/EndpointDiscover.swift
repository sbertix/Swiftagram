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
        private static let base = Endpoint.version1.discover.defaultHeader().locking(authenticator: \.header)

        /// The explore feed.
        public static let explore = base.explore.paginating()
    }
}
