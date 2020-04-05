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
        private static let base = Endpoint.version1.feed.defaultHeader().locking(into: Lock.self)

        /// Stories tray.
        public static let followedStories = base.reels_tray
        /// Liked media.
        public static let likes = base.liked.paginating()
        /// Timeline.
        public static let timeline = base.timeline.paginating()

        /// All posts for user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func posts(by identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.user.append(identifier).paginating()
        }

        /// All available stories for user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func stories(by identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.user.append(identifier).reel_media.paginating()
        }

        /// All posts a user matching `identifier` is tagged in.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func posts(including identifier: String) -> Paginated<Lock<Request>, Response> {
            return Endpoint.version1.usertags
                .append(identifier)
                .feed
                .defaultHeader()
                .locking(into: Lock.self)
                .paginating()
        }

        /// All media matching `tag`.
        /// - parameter tag: A `String` holding reference to a valid _#tag_.
        public static func tagged(with tag: String) -> Paginated<Lock<Request>, Response> {
            return base.tag.append(tag).paginating()
        }
    }
}
