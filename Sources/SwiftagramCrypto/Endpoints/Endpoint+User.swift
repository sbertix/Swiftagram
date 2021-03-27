//
//  Endpoint+User.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 27/03/21.
//

import Foundation

public extension Endpoint.User {
    /// A `struct` defining user request-related endpoints.
    struct Request {
        /// The underlying user.
        let user: Endpoint.User
    }

    /// A wrapper for request endpoints.
    var request: Request {
        .init(user: self)
    }

    /// Block the given user.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    func block() -> Endpoint.Disposable<Status, Error> {
        edit("block")
    }

    /// Follow the given user.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    func follow() -> Endpoint.Disposable<Status, Error> {
        edit("create")
    }

    /// Remove the given user from your followers.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func remove() -> Endpoint.Disposable<Status, Error> {
        edit("remove_follower")
    }

    /// Unblock the given user.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    func unblock() -> Endpoint.Disposable<Status, Error> {
        edit("unblock")
    }

    /// Unfollow the given user.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    func unfollow() -> Endpoint.Disposable<Status, Error> {
        edit("destroy")
    }
}

public extension Endpoint.User.Request {
    /// Accept the follow request.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func approve() -> Endpoint.Disposable<Status, Error> {
        user.edit("approve")
    }

    /// Decline the follow request.
    ///
    /// - returns: A valid `Endpoint.Disposable`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func decline() -> Endpoint.Disposable<Status, Error> {
        user.edit("decline")
    }
}

fileprivate extension Endpoint.User {
    /// Perform an action involving the user matching `identifier`.
    ///
    /// - parameter endpoint: A valid `String`.
    /// - note: **SwiftagramCrypto** only.
    func edit(_ endpoint: String) -> Endpoint.Disposable<Status, Error> {
        .init { secret, session in
            Deferred {
                Endpoint.version1.friendships
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
