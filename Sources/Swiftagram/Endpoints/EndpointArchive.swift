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
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        @available(*, deprecated, message: "use `Endpoint.Media.Stories.archived(startingAt:)` instead")
        public static func stories(startingAt page: String? = nil) -> Paginated<TrayItemCollection> {
            return Endpoint.Media.Stories.archived(startingAt: page)
        }
    }
}
