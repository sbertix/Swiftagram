//
//  Friendship.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 31/07/20.
//

import Foundation

import ComposableRequest

/// A `struct` representing a `Friendship`.
public struct Friendship: ResponseMappable, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var response: () throws -> Response

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

    /// Init.
    /// - parameter response: A valid `Response`.
    public init(response: @autoclosure @escaping () throws -> Response) {
        self.response = response
    }

    /// The debug description.
    public var debugDescription: String {
        ["Friendship(",
         ["isFollowedByYou": isFollowedByYou as Any,
          "isFollowingYou": isFollowingYou as Any,
          "isBlockedByYou": isBlockedByYou as Any,
          "isCloseFriend": isCloseFriend as Any,
          "didRequestToFollowYou": didRequestToFollowYou as Any,
          "didRequestToFollow": didRequestToFollow as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}
