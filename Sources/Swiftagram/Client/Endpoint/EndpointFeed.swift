//
//  EndpointFeed.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

public extension Endpoint {
    /// A `struct` holding reference to `feed` and `usertags` `Endpoint`s. Requires authentication.
    struct Feed {
        /// The base endpoint.
        private static let base = Endpoint.version1.feed.defaultHeader()

        /// Stories tray.
        public static let followedStories = base.reels_tray.locked()
        /// Liked media.
        public static let likes = base.liked.paginating().locked()
        /// Timeline.
        public static let timeline = base.timeline.paginating().locked()

        /// All posts for user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func posts(by identifier: String) -> Locked<Paginated<ComposableRequest>> {
            return base.user.append(identifier).paginating().locked()
        }

        /// All available stories for user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func stories(by identifier: String) -> Locked<Paginated<ComposableRequest>> {
            return base.user.append(identifier).reel_media.paginating().locked()
        }

        /// All posts a user matching `identifier` is tagged in.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func posts(including identifier: String) -> Locked<Paginated<ComposableRequest>> {
            return Endpoint.version1.usertags.append(identifier).feed.defaultHeader().paginating().locked()
        }

        /// All media matching `tag`.
        /// - parameter tag: A `String` holding reference to a valid _#tag_.
        public static func tagged(with tag: String) -> Locked<Paginated<ComposableRequest>> {
            return base.tag.append(tag).paginating().locked()
        }
    }
}
