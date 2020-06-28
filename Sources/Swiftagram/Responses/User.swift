//
//  User.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 23/06/2020.
//

import Foundation

import ComposableRequest

/// A `class` for user-like `Response`s.
public final class User: Response {
    /// An `enum` for access levels.
    public enum Access {
        /// Public accounts.
        case `default`
        /// Private accounts.
        case `private`
        /// Verified accounts.
        case verified
    }

    /// A `struct` holding reference to a `User`'s counters.
    public struct Counter {
        /// The number of posts.
        public var posts: Int
        /// The number of followers.
        public var followers: Int
        /// The number of accounts followed.
        public var following: Int
        /// The number of pictures the `User` is tagged in.
        /// - warning: Defaults to `nil` for `.private` users.
        public var taggedPosts: Int?
        /// The number of InstagramTV videos.
        public var tv: Int
    }

    /// The username.
    public var username: String! { self["username"].string() }
    /// The full name.
    public var name: String? { self["fullName"].string() }
    /// The biography.
    public var biography: String? { self["biography"].string() }

    /// The URL to a low quality avatar asset.
    public var avatar: URL? { self["profilePicUrl"].url() }
    /// The URL to a high quality avatar asset.
    ///
    /// Always fallback to `avatar` when used.
    /// ```swift
    /// let user: User
    /// let avatar = user.betterAvatar ?? user.avatar
    /// ```
    public var betterAvatar: URL? {
        self["hdProfilePicVersions"]
            .array()?
            .max(by: {
                ($0.width.double() ?? 0) < ($1.width.double() ?? 0)
                    && ($0.height.double() ?? 0) < ($1.height.double() ?? 0)
            })?["url"]
            .url() ?? self["hdProfilePicUrlInfo"].url()
    }

    /// The access type.
    public var access: Access {
        self["isPrivate"].bool() == true
            ? .private
            : self["isVerified"].bool() == true
                ? .verified
                : .default
    }

    /// The counter.
    public var counter: Counter? {
        guard let posts = self["mediaCount"].int(),
            let followers = self["followerCount"].int(),
            let following = self["followingCount"].int() else { return nil }
        return .init(posts: posts,
                     followers: followers,
                     following: following,
                     taggedPosts: self["usertagsCount"].int(),
                     tv: self["totalIgTvVideos"].int() ?? 0)
    }
}
