//
//  EndpointExplore.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A module-like `enum` holding reference to `discover` `Endpoint`s. Requires authentication.
    enum Discover {
        /// The base endpoint.
        private static let base = Endpoint.version1.discover.appendingDefaultHeader()

        /// Suggested users.
        ///
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func users(like identifier: String) -> Disposable<Swiftagram.User.Collection> {
            base.chaining
                .appending(query: "target_id", with: identifier)
                .prepare(process: Swiftagram.User.Collection.self)
                .locking(Secret.self)
        }

        /// The explore feed.
        ///
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func explore(startingAt page: String? = nil) -> Paginated<Wrapper> {
            base.explore.paginating(value: page).locking(Secret.self)
        }

        /// The topical explore feed.
        /// 
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func topics(startingAt page: String? = nil) -> Paginated<Wrapper> {
            base.topical_explore
                .paginating()
                .locking(Secret.self) {
                    $0.appending(query: [
                        "is_prefetch": "true",
                        "omit_cover_media": "false",
                        "use_sectional_payload": "true",
                        "timezone_offset": "43200",
                        "session_id": $1["sessionid"]!,
                        "include_fixed_destinations": "false"
                    ]).appending(header: $1.header)
                }
        }
    }
}
