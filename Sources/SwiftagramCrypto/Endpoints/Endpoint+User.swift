//
//  Endpoint+User.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 27/03/21.
//

import Foundation

public extension Endpoint.Group.User {
    /// A `struct` defining user request-related endpoints.
    struct Request {
        /// The underlying user.
        public let user: Endpoint.Group.User
    }

    /// A wrapper for request endpoints.
    var request: Request {
        .init(user: self)
    }

    /// Block the given user.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func block() -> Endpoint.Single<Status, Error> {
        edit("block")
    }

    /// Follow the given user.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func follow() -> Endpoint.Single<Status, Error> {
        edit("create")
    }

    /// Remove the given user from your followers.
    ///
    /// - returns: A valid `Endpoint.Single`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func remove() -> Endpoint.Single<Status, Error> {
        edit("remove_follower")
    }

    /// Unblock the given user.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unblock() -> Endpoint.Single<Status, Error> {
        edit("unblock")
    }

    /// Unfollow the given user.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unfollow() -> Endpoint.Single<Status, Error> {
        edit("destroy")
    }
}

public extension Endpoint.Group.User.Request {
    /// Accept the follow request.
    ///
    /// - returns: A valid `Endpoint.Single`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func approve() -> Endpoint.Single<Status, Error> {
        user.edit("approve")
    }

    /// Decline the follow request.
    ///
    /// - returns: A valid `Endpoint.Single`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func decline() -> Endpoint.Single<Status, Error> {
        user.edit("decline")
    }
}

fileprivate extension Endpoint.Group.User {
    /// Perform an action involving the user matching `identifier`.
    ///
    /// - parameter endpoint: A valid `String`.
    /// - note: **SwiftagramCrypto** only.
    func edit(_ endpoint: String) -> Endpoint.Single<Status, Error> {
        .init { secret, session in
            Deferred {
                Swiftagram.Request.version1
                    .friendships
                    .path(appending: endpoint)
                    .path(appending: self.identifier)
                    .path(appending: "/")
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .signing(body: ["_csrftoken": secret["csrftoken"],
                                    "user_id": self.identifier,
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
}
