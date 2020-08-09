//
//  Friendship.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 31/07/20.
//

import Foundation

import ComposableRequest

/// A `struct` representing a `Friendship`.
public struct Friendship: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// Whether they're followed by the logged in user or not.
    public var isFollowedByYou: Bool? { self["following"].bool() }
    /// Whether they follow the logged in user or not.
    public var isFollowingYou: Bool? { self["followedBy"].bool() }
    /// Whether they're blocked by the logged in user or not.
    public var isBlockedByYou: Bool? { self["blocking"].bool() }
    /// Whether they're in the logged in user's close firends list or not.
    public var isCloseFriend: Bool? { self["isBestie"].bool() }
    /// Whether they've requested to follow the logged in user or not.
    public var didRequestToFollowYou: Bool? { self["incomingRequest"].bool() }
    /// Whether the logged in user have requested to follow them or not.
    public var didRequestToFollow: Bool? { self["outgoingRequest"].bool() }

    /// Whether the logged in user is muting their stories.
    public var isMutingStories: Bool? { self["isMutingReel"].bool() }
    /// Whether the logged in user is muting their posts.
    public var isMutingPosts: Bool? { self["muting"].bool() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }

    /// The debug description.
    public var debugDescription: String {
        ["Friendship(",
         ["isFollowedByYou": isFollowedByYou as Any,
          "isFollowingYou": isFollowingYou as Any,
          "isBlockedByYou": isBlockedByYou as Any,
          "isCloseFriend": isCloseFriend as Any,
          "didRequestToFollowYou": didRequestToFollowYou as Any,
          "didRequestToFollow": didRequestToFollow as Any,
          "isMutingStories": isMutingStories as Any,
          "isMutingPosts": isMutingPosts as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}

/// A `struct` representing a `Friendship` collection.
public struct FriendshipCollection: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The friendships.
    public var friendships: [String: Friendship]! { self["friendshipStatuses"].dictionary()?.mapValues { Friendship(wrapper: $0) }}
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }

    /// The debug description.
    public var debugDescription: String {
        ["FriendshipCollection(",
         ["friendships": friendships as Any,
          "status": status as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}
