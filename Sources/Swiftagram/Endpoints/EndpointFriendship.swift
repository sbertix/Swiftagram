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
            return base.locking(into: Lock.self).append(identifier).following.paginating()
        }

        /// A list of users following the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        /// - note: This is equal to the user's **followers**.
        public static func following(_ identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.locking(into: Lock.self).append(identifier).followers.paginating()
        }

        /// The current friendship status between the authenticated user and the one matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func friendship(with identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.locking(into: Lock.self).show.append(identifier).paginating()
        }

        /// A list of users who requested to follow you, without having been processed yet.
        public static let pendingRequests = base.locking(into: Lock.self).pending.paginating()

        // MARK: Actions
        /// Follow (or send a follow request) the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func follow(_ identifier: String) -> CustomLock<Request> {
            return base.create.append(identifier)
                .locking {
                    guard let secret = $1 as? Secret else {
                        fatalError("A `Swiftagram.Secret` is required to authenticate `.follow`.")
                    }
                    return $0.header(secret.headerFields)
                        .body("_csrftoken", value: secret.crossSiteRequestForgery.value)
                        .body("_uuid", value: Device.default.deviceGUID.uuidString)
                        .body("_uid", value: secret.id)
                        .body("user_id", value: identifier)
                        .body("radio_type", value: "wifi-none")
                }
        }

        /// Unfollow the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func unfollow(_ identifier: String) -> CustomLock<Request> {
            return base.destroy.append(identifier)
                .locking {
                    guard let secret = $1 as? Secret else {
                        fatalError("A `Swiftagram.Secret` is required to authenticate `.unfollow`.")
                    }
                    return $0.header(secret.headerFields)
                        .body("_csrftoken", value: secret.crossSiteRequestForgery.value)
                        .body("_uuid", value: Device.default.deviceGUID.uuidString)
                        .body("_uid", value: secret.id)
                        .body("user_id", value: identifier)
                        .body("radio_type", value: "wifi-none")
                }
        }

        /// Remove a user following you, matching the `identifier`. Said user will stop following you.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func remove(follower identifier: String) -> CustomLock<Request> {
            return base.remove_follower.append(identifier)
                .locking {
                    guard let secret = $1 as? Secret else {
                        fatalError("A `Swiftagram.Secret` is required to authenticate `.remove`.")
                    }
                    return $0.header(secret.headerFields)
                        .body("_csrftoken", value: secret.crossSiteRequestForgery.value)
                        .body("_uuid", value: Device.default.deviceGUID.uuidString)
                        .body("_uid", value: secret.id)
                        .body("user_id", value: identifier)
                        .body("radio_type", value: "wifi-none")
                }
        }

        /// Accept a follow request from the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func acceptRequest(from identifier: String) -> CustomLock<Request> {
            return base.approve.append(identifier)
                .locking {
                    guard let secret = $1 as? Secret else {
                        fatalError("A `Swiftagram.Secret` is required to authenticate `.acceptRequest`.")
                    }
                    return $0.header(secret.headerFields)
                        .body("_csrftoken", value: secret.crossSiteRequestForgery.value)
                        .body("_uuid", value: Device.default.deviceGUID.uuidString)
                        .body("_uid", value: secret.id)
                        .body("user_id", value: identifier)
                        .body("radio_type", value: "wifi-none")
                }
        }

        /// Reject a follow request from the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func rejectRequest(from identifier: String) -> CustomLock<Request> {
            return base.reject.append(identifier)
                .locking {
                    guard let secret = $1 as? Secret else {
                        fatalError("A `Swiftagram.Secret` is required to authenticate `.rejectRequest`.")
                    }
                    return $0.header(secret.headerFields)
                        .body("_csrftoken", value: secret.crossSiteRequestForgery.value)
                        .body("_uuid", value: Device.default.deviceGUID.uuidString)
                        .body("_uid", value: secret.id)
                        .body("user_id", value: identifier)
                        .body("radio_type", value: "wifi-none")
                }
        }

        /// Block the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func block(_ identifier: String) -> CustomLock<Request> {
            return base.block.append(identifier)
                .locking {
                    guard let secret = $1 as? Secret else {
                        fatalError("A `Swiftagram.Secret` is required to authenticate `.block`.")
                    }
                    return $0.header(secret.headerFields)
                        .body("_csrftoken", value: secret.crossSiteRequestForgery.value)
                        .body("_uuid", value: Device.default.deviceGUID.uuidString)
                        .body("_uid", value: secret.id)
                        .body("user_id", value: identifier)
                        .body("radio_type", value: "wifi-none")
                }
        }

        /// Unblock the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func unblock(_ identifier: String) -> CustomLock<Request> {
            return base.unblock.append(identifier)
                .locking {
                    guard let secret = $1 as? Secret else {
                        fatalError("A `Swiftagram.Secret` is required to authenticate `.unblock`.")
                    }
                    return $0.header(secret.headerFields)
                        .body("_csrftoken", value: secret.crossSiteRequestForgery.value)
                        .body("_uuid", value: Device.default.deviceGUID.uuidString)
                        .body("_uid", value: secret.id)
                        .body("user_id", value: identifier)
                        .body("radio_type", value: "wifi-none")
                }
        }
    }
}
