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
        private static let base = Endpoint.version1.feed.defaultHeaderFields()

        /// Stories tray.
        public static let followedStories = base.reels_tray
        /// Liked media.
        public static let likes = base.liked
        /// Timeline.
        public static let timeline = base.timeline

        /// All posts for user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func posts(by identifier: String) -> Endpoint {
            return base.user.wrap(identifier)
        }
        /// All available stories for user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func stories(by identifier: String) -> Endpoint {
            return base.reelMedia.wrap(identifier)
        }
        /// All posts a user matching `identifier` is tagged in.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func posts(including identifier: String) -> Endpoint {
            return Endpoint.version1.usertags.wrap(identifier).feed.defaultHeaderFields()
        }

        /// All media matching `tag`.
        /// - parameter tag: A `String` holding reference to a valid _#tag_.
        public static func tagged(with tag: String) -> Endpoint {
            return base.tag.wrap(tag)
        }
    }
}
