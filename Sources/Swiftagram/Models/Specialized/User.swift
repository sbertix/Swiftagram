//
//  User.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 31/07/20.
//

import Foundation

/// A `struct` representing a `User`.
public struct User: Wrapped {
    /// An `enum` representing an access status.
    public struct Access: OptionSet, Hashable, Codable {
        /// The underlying raw value.
        public let rawValue: Int

        /// Init.
        ///
        /// - parameter rawValue: A valid `Int`.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// A private account.
        public static let `private`: Access = .init(rawValue: 1 << 0)
        /// A verified account.
        public static let verified: Access = .init(rawValue: 1 << 1)
        /// A business account.
        public static let business: Access = .init(rawValue: 1 << 2)
        /// A creator account.
        public static let creator: Access = .init(rawValue: 1 << 3)
    }

    /// A `struct` representing a profile's `Counter`s.
    public struct Counter: Hashable, Codable {
        /// Posts.
        public var posts: Int
        /// Followers.
        public var followers: Int
        /// Following.
        public var following: Int
        /// Posts in which their tagged in.
        public var tags: Int
        /// Clips.
        public var clips: Int
        /// AR effects.
        public var effects: Int
        /// IGTV.
        public var igtv: Int
    }

    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The identifier.
    public var identifier: String! { self["pk"].string(converting: true) }
    /// The username.
    public var username: String! { self["username"].string() }
    /// The name.
    public var name: String? { self["fullName"].string() }
    /// The biography.
    public var biography: String? { self["biography"].string() }
    /// The category.
    public var category: String? { self["category"].string() }
    /// A lower quality avatar.
    public var thumbnail: URL? { self["profilePicUrl"].url() }
    /// An higher quality avatar.
    public var avatar: URL? {
        self["hdProfilePicVersions"]
            .array()?
            .max {
                ($0.width.double() ?? 0) < ($1.width.double() ?? 0)
                    && ($0.height.double() ?? 0) < ($1.height.double() ?? 0)
            }?["url"]
            .url() ?? self["hdProfilePicUrlInfo"]["url"].url()
    }

    /// The current access status.
    public var access: Access? {
        let isPrivate = self["isPrivate"].bool()
        let isVerified = self["isVerified"].bool()
        let isBusiness = self["isBusiness"].bool()
        let account = self["accountType"].int()
        // Deal with condition.
        guard isPrivate != nil || isVerified != nil || isBusiness != nil || account != nil else { return nil }
        var access: Access = []
        if isPrivate ?? false { access.formUnion(.private) }
        if isVerified ?? false { access.formUnion(.verified) }
        if (isBusiness ?? false) || account == 2 { access.formUnion(.business) }
        if account == 3 { access.formUnion(.creator) }
        return access
    }

    /// An optional friendship status.
    public var friendship: Friendship? {
        self["friendship"].optional().flatMap(Friendship.init)
            ?? self["friendshipStatus"].optional().flatMap(Friendship.init)
    }

    /// The counter.
    public var counter: Counter? {
        guard let posts = self["mediaCount"].int(),
              let followers = self["followerCount"].int(),
              let following = self["followingCount"].int() else { return nil }
        return .init(posts: posts,
                     followers: followers,
                     following: following,
                     tags: self["usertagsCount"].int() ?? 0,
                     clips: self["totalClipsCount"].int() ?? 0,
                     effects: self["totalArEffects"].int() ?? 0,
                     igtv: self["totalIgtvVideos"].int() ?? 0)
    }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }
}

public extension User {
    /// A `struct` representing a `User` single response.
    struct Unit: Specialized {
        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The user.
        public var user: User? { self["user"].optional().flatMap(User.init) }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }

    /// A `struct` representing a `User` collection.
    struct Collection: Specialized, StringPaginatable {
        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The users.
        public var users: [User]? { self["users"].array()?.map(User.init) }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }
}
