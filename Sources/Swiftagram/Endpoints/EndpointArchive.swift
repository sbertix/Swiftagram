//
//  EndpointArchive.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A `struct` holding reference to `archive` `Endpoint`s. Requires authentication.
    struct Archive {
        /// The base endpoint.
        private static let base = Endpoint.version1.archive.appendingDefaultHeader()
        /// Archived stories.
        public static let stories: ResponsePaginated = base.reel.day_shells.paginating().locking(Secret.self)
    }
}
