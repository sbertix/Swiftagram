//
//  Endpoints.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

/// A `struct` holding reference to frequently used `Endpoint`s.
public struct Endpoints {
    /// A `struct` holding reference to `archive` `Endpoint`s. Requires authentication.
    public struct Archive {
        /// The base endpoint.
        private static let base = Endpoint.version1.archive.defaultHeaderFields()
        /// Archived stories.
        public static let stories = base.reel.day_shells
    }

    /// A `struct` holding reference to `direct_v2` `Endpoint`s. Requires authentication.
    public struct Direct {
        /// The base endpoint.
        private static let base = Endpoint.version1.direct_v2.defaultHeaderFields()

        /// All threads.
        public static let threads = base.reel.inbox

        /// A thread matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid thread identifier.
        public static func thread(matching identifier: String) -> Endpoint {
            return base.threads.wrap(identifier)
        }
    }

    /// A `struct` holding reference to `feed` and `usertags` `Endpoint`s. Requires authentication.
    public struct Feed {
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

    /// A `struct` holding reference to `friendships` `Endpoint`s. Requires authentication.
    public struct Friendship {
        /// The base endpoint.
        private static let base = Endpoint.version1.friendships.defaultHeaderFields()

        /// A list of users followed by the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        /// - note: This is equal to the user's **following**.
        public static func followed(by identifier: String) -> Endpoint {
            return base.wrap(identifier).following
        }
        /// A list of users following the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        /// - note: This is equal to the user's **followers**.
        public static func following(_ identifier: String) -> Endpoint {
            return base.wrap(identifier).followers
        }
        /// The current friendship status between the authenticated user and the one matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func friendship(with identifier: String) -> Endpoint {
            return base.show.wrap(identifier)
        }
    }

    /// A `struct` holding reference to `users` `Endpoint`s. Requires authentication.
    public struct User {
        /// The base endpoint.
        private static let base = Endpoint.version1.users.defaultHeaderFields()

        /// A user matching `identifier`'s info.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func summary(for identifier: String) -> Endpoint {
            return base.wrap(identifier).info
        }
        /// All user matching `query`.
        /// - parameter query: A `String` holding reference to a valid user query.
        public static func all(matching query: String) -> Endpoint {
            return base.search.query(key: "q", value: query)
        }
    }
}
