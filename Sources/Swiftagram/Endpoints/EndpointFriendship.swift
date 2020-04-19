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
        private static let base = Endpoint.version1.friendships.defaultHeader()

        // MARK: Info
        /// A list of users followed by the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        /// - note: This is equal to the user's **following**.
        public static func followed(by identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.locking(authenticator: \.header).append(identifier).following.paginating()
        }

        /// A list of users following the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        /// - note: This is equal to the user's **followers**.
        public static func following(_ identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.locking(authenticator: \.header).append(identifier).followers.paginating()
        }

        /// The current friendship status between the authenticated user and the one matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func friendship(with identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.locking(authenticator: \.header).show.append(identifier).paginating()
        }

        /// A list of users who requested to follow you, without having been processed yet.
        public static let pendingRequests = base.locking(authenticator: \.header).pending.paginating()

        // MARK: Actions
        /// Perform an action involving the user matching `identifier`.
        /// - parameters:
        ///     - transformation: A `KeyPath` defining the endpoint path.
        ///     - identifier: A `String` holding reference to a valid user identifier.
        private static func edit(_ keyPath: KeyPath<Request, Request>, _ identifier: String) -> Lock<Request> {
            return base[keyPath: keyPath].append(identifier)
                .locking {
                    guard let secret = $0.key as? Secret else {
                        fatalError("A `Swiftagram.Secret` is required to authenticate `Friendship` actions.")
                    }
                    // return.
                    return $0.request.header(secret.header)
                        .signedBody(["_csrftoken": secret.crossSiteRequestForgery.value,
                                     "user_id": identifier,
                                     "radio_type": "wifi-none",
                                     "_uid": secret.identifier,
                                     "device_id": Device.default.deviceIdentifier,
                                     "_uuid": Device.default.deviceGUID.uuidString])
                }
        }

        /// Follow (or send a follow request) the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func follow(_ identifier: String) -> Lock<Request> {
            return edit(\.create, identifier)
        }

        /// Unfollow the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func unfollow(_ identifier: String) -> Lock<Request> {
            return edit(\.destroy, identifier)
        }

        /// Remove a user following you, matching the `identifier`. Said user will stop following you.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func remove(follower identifier: String) -> Lock<Request> {
            return edit(\.remove_follower, identifier)
        }

        /// Accept a follow request from the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func acceptRequest(from identifier: String) -> Lock<Request> {
            return edit(\.approve, identifier)
        }

        /// Reject a follow request from the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func rejectRequest(from identifier: String) -> Lock<Request> {
            return edit(\.reject, identifier)
        }

        /// Block the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func block(_ identifier: String) -> Lock<Request> {
            return edit(\.block, identifier)
        }

        /// Unblock the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func unblock(_ identifier: String) -> Lock<Request> {
            return edit(\.unblock, identifier)
        }
    }
}
