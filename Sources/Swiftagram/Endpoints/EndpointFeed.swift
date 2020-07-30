//
//  EndpointFeed.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A `struct` holding reference to `feed` and `usertags` `Endpoint`s. Requires authentication.
    struct Feed {
        /// The base endpoint.
        private static let base = Endpoint.version1.feed.appendingDefaultHeader()

        /// Stories tray.
        public static let followedStories: DisposableResponse = base.reels_tray.prepare().locking(Secret.self)

        /// Liked media.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func liked(startingAt page: String? = nil) -> PaginatedResponse {
            return base.liked.paginating(value: page).locking(Secret.self)
        }

        /// All saved media.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func saved(startingAt page: String? = nil) -> PaginatedResponse {
            return base.saved
                .appending(header: "include_igtv_preview", with: "false")
                .paginating(value: page)
                .locking(Secret.self)
        }

        @available(*, unavailable, message: "we are working on adding this back. Do not file an issue.")
        /// Timeline.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func timeline(startingAt page: String? = nil) -> PaginatedResponse {
            fatalError("Removed.")
        }

        /// All posts for user matching `identifier`.
        /// - parameters:
        ///     - identifier: A `String` holding reference to a valid user identifier.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func posts(by identifier: String, startingAt page: String? = nil) -> PaginatedResponse {
            return base.user.appending(path: identifier).paginating(value: page).locking(Secret.self)
        }

        /// All available stories for user matching `identifier`.
        /// - parameters
        ///     - identifier: A `String` holding reference to a valid user identifier.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.`
        public static func stories(by identifier: String, startingAt page: String? = nil) -> PaginatedResponse {
            return base.user.appending(path: identifier).reel_media.paginating(value: page).locking(Secret.self)
        }

        /// All posts a user matching `identifier` is tagged in.
        /// - parameters
        ///     - identifier: A `String` holding reference to a valid user identifier.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func posts(including identifier: String, startingAt page: String? = nil) -> PaginatedResponse {
            return Endpoint.version1.usertags
                .appending(path: identifier)
                .feed
                .appendingDefaultHeader()
                .paginating(value: page)
                .locking(Secret.self)
        }

        /// All media matching `tag`.
        /// - parameters:
        ///     - tag: A `String` holding reference to a valid _#tag_.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func tagged(with tag: String, startingAt page: String? = nil) -> PaginatedResponse {
            return base.tag.appending(path: tag).paginating(value: page).locking(Secret.self)
        }
    }
}
