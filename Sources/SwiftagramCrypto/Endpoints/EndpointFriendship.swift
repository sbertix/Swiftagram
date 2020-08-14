//
//  EndpointFriendship.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest
import Swiftagram

public extension Endpoint.Friendship {
    /// The base endpoint.
    private static let base = Endpoint.version1.friendships.appendingDefaultHeader()

    // MARK: Actions
    /// Perform an action involving the user matching `identifier`.
    /// - parameters:
    ///     - transformation: A `KeyPath` defining the endpoint path.
    ///     - identifier: A `String` holding reference to a valid user identifier.
    private static func edit(_ keyPath: KeyPath<Request, Request>, _ identifier: String) -> Endpoint.Disposable<Wrapper> {
        return base[keyPath: keyPath]
            .appending(path: identifier)
            .appending(path: "/")
            .prepare()
            .locking(Secret.self) {
                $0.appending(header: $1.header)
                    .signing(body: ["_csrftoken": $1.crossSiteRequestForgery.value,
                                    "user_id": identifier,
                                    "radio_type": "wifi-none",
                                    "_uid": $1.id,
                                    "device_id": $1.device.deviceIdentifier,
                                    "_uuid": $1.device.deviceGUID.uuidString])
        }
    }

    /// Follow (or send a follow request) the user matching `identifier`.
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    static func follow(_ identifier: String) -> Endpoint.Disposable<Wrapper> {
        return edit(\.create, identifier)
    }

    /// Unfollow the user matching `identifier`.
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    static func unfollow(_ identifier: String) -> Endpoint.Disposable<Wrapper> {
        return edit(\.destroy, identifier)
    }

    /// Remove a user following you, matching the `identifier`. Said user will stop following you.
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    static func remove(follower identifier: String) -> Endpoint.Disposable<Wrapper> {
        return edit(\.remove_follower, identifier)
    }

    /// Accept a follow request from the user matching `identifier`.
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    static func acceptRequest(from identifier: String) -> Endpoint.Disposable<Wrapper> {
        return edit(\.approve, identifier)
    }

    /// Reject a follow request from the user matching `identifier`.
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    static func rejectRequest(from identifier: String) -> Endpoint.Disposable<Wrapper> {
        return edit(\.reject, identifier)
    }

    /// Block the user matching `identifier`.
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    static func block(_ identifier: String) -> Endpoint.Disposable<Wrapper> {
        return edit(\.block, identifier)
    }

    /// Unblock the user matching `identifier`.
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    static func unblock(_ identifier: String) -> Endpoint.Disposable<Wrapper> {
        return edit(\.unblock, identifier)
    }
}
