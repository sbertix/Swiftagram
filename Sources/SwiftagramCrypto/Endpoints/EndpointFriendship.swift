//
//  EndpointFriendship.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import Swiftagram

public extension Endpoint.Friendship {
    /// The base endpoint.
    private static let base = Endpoint.version1.friendships.appendingDefaultHeader()

    /// Perform an action involving the user matching `identifier`.
    ///
    /// - parameters:
    ///     - transformation: A `KeyPath` defining the endpoint path.
    ///     - identifier: A `String` holding reference to a valid user identifier.
    /// - note: **SwiftagramCrypto** only.
    private static func edit(_ keyPath: KeyPath<Request, Request>, _ identifier: String) -> Endpoint.Disposable<Status, Error> {
        .init { secret, session in
            Deferred {
                base[keyPath: keyPath]
                    .path(appending: identifier)
                    .path(appending: "/")
                    .header(appending: secret.header)
                    .signing(body: ["_csrftoken": secret["csrftoken"],
                                    "user_id": identifier,
                                    "radio_type": "wifi-none",
                                    "_uid": secret.identifier,
                                    "device_id": secret.client.device.instagramIdentifier,
                                    "_uuid": secret.client.device.identifier.uuidString])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Status.init)
            }
            .eraseToAnyPublisher()
        }
    }

    /// Follow (or send a follow request) the user matching `identifier`.
    ///
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    /// - note: **SwiftagramCrypto** only.
    static func follow(_ identifier: String) -> Endpoint.Disposable<Status, Error> {
        edit(\.create, identifier)
    }

    /// Unfollow the user matching `identifier`.
    ///
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    /// - note: **SwiftagramCrypto** only.
    static func unfollow(_ identifier: String) -> Endpoint.Disposable<Status, Error> {
        edit(\.destroy, identifier)
    }

    /// Remove a user following you, matching the `identifier`. Said user will stop following you.
    ///
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    /// - note: **SwiftagramCrypto** only.
    static func remove(follower identifier: String) -> Endpoint.Disposable<Status, Error> {
        edit(\.remove_follower, identifier)
    }

    /// Accept a follow request from the user matching `identifier`.
    ///
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    /// - note: **SwiftagramCrypto** only.
    static func acceptRequest(from identifier: String) -> Endpoint.Disposable<Status, Error> {
        edit(\.approve, identifier)
    }

    /// Reject a follow request from the user matching `identifier`.
    ///
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    /// - note: **SwiftagramCrypto** only.
    static func rejectRequest(from identifier: String) -> Endpoint.Disposable<Status, Error> {
        edit(\.reject, identifier)
    }

    /// Block the user matching `identifier`.
    ///
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    /// - note: **SwiftagramCrypto** only.
    static func block(_ identifier: String) -> Endpoint.Disposable<Status, Error> {
        edit(\.block, identifier)
    }

    /// Unblock the user matching `identifier`.
    ///
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    /// - note: **SwiftagramCrypto** only.
    static func unblock(_ identifier: String) -> Endpoint.Disposable<Status, Error> {
        edit(\.unblock, identifier)
    }
}
