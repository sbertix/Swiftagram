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
        private static let base = Endpoint.version1.archive.defaultHeader().locking(authenticator: \.header)
        /// Archived stories.
        public static let stories = base.reel.day_shells.paginating()
    }
}
