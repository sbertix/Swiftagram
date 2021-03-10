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
        public static func users(like identifier: String) -> Disposable<Swiftagram.User.Collection, Error> {
            .init { secret, session in
                Deferred {
                    base.chaining
                        .query(appending: identifier, forKey: "target_id")
                        .header(appending: secret.header)
                        .project(session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.User.Collection.init)
                }
                .receive(on: session.scheduler)
                .eraseToAnyPublisher()
            }
        }

        /// The explore feed.
        public static var explore: Paginated<Page<Wrapper, String?>, String?, Error> {
            .init { secret, session, pages in
                Pager(pages) { _, next, _ in
                    base.explore
                        .header(appending: secret.header)
                        .query(appending: next, forKey: "max_id")
                        .project(session)
                        .map(\.data)
                        .wrap()
                }
                .receive(on: session.scheduler)
                .eraseToAnyPublisher()
            }
        }

        /// The topical explore feed.
        /// 
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static var topics: Paginated<Page<Wrapper, String?>, String?, Error> {
            .init { secret, session, pages in
                Pager(pages) { _, next, _ in
                    base.topical_explore
                        .header(appending: secret.header)
                        .query(appending: ["is_prefetch": "true",
                                           "omit_cover_media": "false",
                                           "use_sectional_payload": "true",
                                           "timezone_offset": "43200",
                                           "session_id": secret["sessionid"]!,
                                           "include_fixed_destinations": "false",
                                           "max_id": next])
                        .project(session)
                        .map(\.data)
                        .wrap()
                }
                .receive(on: session.scheduler)
                .eraseToAnyPublisher()
            }
        }
    }
}
