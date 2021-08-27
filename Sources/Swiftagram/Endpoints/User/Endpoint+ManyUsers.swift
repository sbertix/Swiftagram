//
//  Endpoint+ManyUsers.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/03/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `class` defining users-related endpoints.
    final class ManyUsers {
        /// The user identifiers.
        public let identifiers: [String]

        /// Init.
        ///
        /// - parameter identifiers: An array of `String`s.
        init(identifiers: [String]) {
            self.identifiers = identifiers
        }
    }
}

public extension Endpoint {
    /// A wrapper for users specific endpoints.
    ///
    /// - parameter identifiers: A collection of `String`s.
    /// - returns: A valid `Endpoint.ManyUsers`.
    static func users<C: Collection>(_ identifiers: C) -> Group.ManyUsers where C.Element == String {
        .init(identifiers: Array(identifiers))
    }

    /// A wrapper for users specific endpoints.
    ///
    /// - parameter users: A collection of `User`s.
    /// - returns: A valid `Endpoint.ManyUsers`.
    static func users<C: Collection>(_ users: C) -> Group.ManyUsers where C.Element == Swiftagram.User {
        self.users(users.compactMap(\.identifier))
    }
}

public extension Endpoint.Group.ManyUsers {
    /// List all friendship statuses between the list of users and the logged in one.
    var friendships: Endpoint.Single<Swiftagram.Friendship.Dictionary> {
        .init { secret, requester in
            Request.friendships
                .path(appending: "show_many/")
                .header(appending: secret.header)
                .body(["user_ids": self.identifiers.joined(separator: ","),
                       "_csrftoken": secret["csrftoken"],
                       "_uuid": secret.client.device.identifier.uuidString])
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Swiftagram.Friendship.Dictionary.init)
                .requested(by: requester)
        }
    }

    /// List all recent stories by the list of users.
    var stories: Endpoint.Single<TrayItem.Dictionary> {
        .init { secret, requester in
            Request.version1
                .feed
                .path(appending: "reels_media/")
                .appendingDefaultHeader()
                .header(appending: secret.header)
                .body(["user_ids": "[\(self.identifiers.joined(separator: ","))]"])
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(TrayItem.Dictionary.init)
                .requested(by: requester)
        }
    }
}
