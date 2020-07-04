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

        /// Suggested users.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func users(like identifier: String) -> ResponseDisposable {
            return base.chaining.appending(query: "target_id", with: identifier).prepare().locking(Secret.self)
        }

        /// The explore feed.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func explore(startingAt page: String? = nil) -> ResponsePaginated {
            return base.explore.paginating(value: page).locking(Secret.self)
        }

        /// The topical explore feed.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func topics(startingAt page: String? = nil) -> ResponsePaginated {
            return base.topical_explore
                .paginating()
                .locking(Secret.self) {
                    $0.appending(query: [
                        "is_prefetch": "true",
                        "omit_cover_media": "false",
                        "use_sectional_payload": "true",
                        "timezone_offset": "43200",
                        "session_id": $1.session.value,
                        "include_fixed_destinations": "false"
                    ])
                }
        }
    }
}
