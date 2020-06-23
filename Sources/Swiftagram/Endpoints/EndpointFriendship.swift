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
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        /// - note: This is equal to the user's **following**.
        public static func followed(by identifier: String) -> ResponsePaginated {
            return base.appending(path: identifier).following.paginating().locking(Secret.self)
        }

        /// A list of users following the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        /// - note: This is equal to the user's **followers**.
        public static func following(_ identifier: String) -> ResponsePaginated {
            return base.appending(path: identifier).followers.paginating().locking(Secret.self)
        }

        /// The current friendship status between the authenticated user and the one matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func friendship(with identifier: String) -> ResponsePaginated {
            return base.show.appending(path: identifier).paginating().locking(Secret.self)
        }

        /// A list of users who requested to follow you, without having been processed yet.
        public static let pendingRequests: ResponsePaginated = base.pending.paginating().locking(Secret.self)

        // MARK: Actions
        /// Perform an action involving the user matching `identifier`.
        /// - parameters:
        ///     - transformation: A `KeyPath` defining the endpoint path.
        ///     - identifier: A `String` holding reference to a valid user identifier.
        private static func edit(_ keyPath: KeyPath<Request, Request>, _ identifier: String) -> ResponseDisposable {
            return base[keyPath: keyPath]
                .appending(path: identifier)
                .prepare()
                .locking(Secret.self) {
                    $0.appending(header: $1.header)
                        .signing(body: ["_csrftoken": $1.crossSiteRequestForgery.value,
                                        "user_id": identifier,
                                        "radio_type": "wifi-none",
                                        "_uid": $1.identifier ?? "",
                                        "device_id": Device.default.deviceIdentifier,
                                        "_uuid": Device.default.deviceGUID.uuidString])
                }
        }

        /// Follow (or send a follow request) the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func follow(_ identifier: String) -> ResponseDisposable {
            return edit(\.create, identifier)
        }

        /// Unfollow the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func unfollow(_ identifier: String) -> ResponseDisposable {
            return edit(\.destroy, identifier)
        }

        /// Remove a user following you, matching the `identifier`. Said user will stop following you.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func remove(follower identifier: String) -> ResponseDisposable {
            return edit(\.remove_follower, identifier)
        }

        /// Accept a follow request from the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func acceptRequest(from identifier: String) -> ResponseDisposable {
            return edit(\.approve, identifier)
        }

        /// Reject a follow request from the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func rejectRequest(from identifier: String) -> ResponseDisposable {
            return edit(\.reject, identifier)
        }

        /// Block the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func block(_ identifier: String) -> ResponseDisposable {
            return edit(\.block, identifier)
        }

        /// Unblock the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func unblock(_ identifier: String) -> ResponseDisposable {
            return edit(\.unblock, identifier)
        }
    }
}
