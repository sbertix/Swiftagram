//
//  Friendship.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 20/03/21.
//

import Foundation

import Swiftagram

extension Friendship: Reflected {
    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["isFollowedByYou": \Self.isFollowedByYou,
                                                                    "isFollowingYou": \Self.isFollowingYou,
                                                                    "isBlockedByYou": \Self.isBlockedByYou,
                                                                    "isCloseFriend": \Self.isCloseFriend,
                                                                    "didRequestToFollowYou": \Self.didRequestToFollowYou,
                                                                    "didRequestToFollow": \Self.didRequestToFollow,
                                                                    "isMutingStories": \Self.isMutingStories,
                                                                    "isMutingPosts": \Self.isMutingPosts]
}

extension Friendship.Dictionary: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "Friendship." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["friendships": \Self.friendships,
                                                                    "error": \Self.error]
}
