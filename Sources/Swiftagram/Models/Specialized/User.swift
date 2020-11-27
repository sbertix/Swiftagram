//
//  User.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 31/07/20.
//

import Foundation

import ComposableRequest

/// A `struct` representing a `User`.
public struct User: ReflectedType {
    /// An `enum` representing an access status.
    public enum Access: Int, Hashable, Codable {
        /// Default.
        case `default`
        /// Private.
        case `private`
        /// Verified.
        case verified
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

    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["identifier": \Self.identifier,
                                                                    "username": \Self.username,
                                                                    "name": \Self.name,
                                                                    "biography": \Self.biography,
                                                                    "thumbnail": \Self.thumbnail,
                                                                    "avatar": \Self.avatar,
                                                                    "access": \Self.access,
                                                                    "counter": \Self.counter,
                                                                    "friendship": \Self.friendship]

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
    /// A lower quality avatar.
    public var thumbnail: URL? { self["profilePicUrl"].url() }
    /// An higher quality avatar.
    public var avatar: URL? {
        self["hdProfilePicVersions"]
            .array()?
            .max(by: {
                ($0.width.double() ?? 0) < ($1.width.double() ?? 0)
                    && ($0.height.double() ?? 0) < ($1.height.double() ?? 0)
            })?["url"]
            .url() ?? self["hdProfilePicUrlInfo"]["url"].url()
    }

    /// The current access status.
    public var access: Access? {
        if self["isPrivate"].bool() == nil && self["isVerified"].bool() == nil {
            return nil
        } else if self["isPrivate"].bool() ?? false {
            return .private
        } else if self["isVerified"].bool() ?? false {
            return .verified
        }
        return .default
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
    struct Unit: ResponseType, ReflectedType {
        /// The prefix.
        public static var debugDescriptionPrefix: String { "Comment." }
        /// A list of to-be-reflected properties.
        public static let properties: [String: PartialKeyPath<Self>] = ["user": \Self.user,
                                                                        "error": \Self.error]

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
    struct Collection: ResponseType, ReflectedType, PaginatedType {
        /// The prefix.
        public static var debugDescriptionPrefix: String { "User." }
        /// A list of to-be-reflected properties.
        public static let properties: [String: PartialKeyPath<Self>] = ["users": \Self.users,
                                                                        "pagination": \Self.pagination,
                                                                        "error": \Self.error]
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
