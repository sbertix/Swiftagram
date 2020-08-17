//
//  EndpointFriendship.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A `struct` holding reference to `friendships` `Endpoint`s. Requires authentication.
    struct Friendship {
        /// The base endpoint.
        private static let base = Endpoint.version1.friendships.appendingDefaultHeader()

        // MARK: Info
        /// A list of users followed by the user matching `identifier`.
        /// - parameters:
        ///     - identifier: A `String` holding reference to a valid user identifier.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        /// - note: This is equal to the user's **following**.
        public static func followed(by identifier: String, startingAt page: String? = nil) -> Paginated<UserCollection> {
            return base.appending(path: identifier)
                .following
                .paginating(process: UserCollection.self, value: page)
                .locking(Secret.self)
        }

        /// A list of users following the user matching `identifier`.
        /// - parameters:
        ///     - identifier: A `String` holding reference to a valid user identifier.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        /// - note: This is equal to the user's **followers**.
        public static func following(_ identifier: String, startingAt page: String? = nil) -> Paginated<UserCollection> {
            return base.appending(path: identifier)
                .followers
                .paginating(process: UserCollection.self,
                            value: page)
                .locking(Secret.self)
        }

        /// The current friendship status between the authenticated user and the one matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func summary(for identifier: String) -> Disposable<Swiftagram.Friendship> {
            return base.show
                .appending(path: identifier)
                .prepare(process: Swiftagram.Friendship.self)
                .locking(Secret.self)
        }

        /// The current friendship status between the authenticated user and all users matching `identifiers`.
        /// - parameter identifiers: A collection of `String`s hoding reference to valid user identifiers.
        public static func summary<C: Collection>(for identifiers: C) -> Disposable<FriendshipCollection> where C.Element == String {
            return base.appending(path: "show_many/")
                .prepare(process: FriendshipCollection.self)
                .locking(Secret.self) {
                    $0.appending(header: $1.header)
                        .replacing(body: [
                            "user_ids": identifiers.joined(separator: ","),
                            "_csrftoken": $1.crossSiteRequestForgery.value,
                            "_uuid": $1.device.deviceGUID.uuidString
                        ])
                }
        }

        /// A list of users who requested to follow you, without having been processed yet.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func pendingRequests(startingAt page: String? = nil) -> Paginated<UserCollection> {
            return base.pending.paginating(process: UserCollection.self).locking(Secret.self)
        }

        // MARK: Deprecated
        /// The current friendship status between the authenticated user and the one matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func friendship(with identifier: String) -> Disposable<Swiftagram.Friendship> {
            return summary(for: identifier)
        }
    }
}
