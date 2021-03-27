//
//  Endpoint+ManyUsers.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/03/21.
//

import Foundation

public extension Endpoint {
    /// A `struct` defining users-related endpoints.
    struct ManyUsers {
        /// The user identifiers.
        public let identifiers: [String]
    }

    /// A wrapper for users specific endpoints.
    ///
    /// - parameter identifiers: A collection of `String`s.
    /// - returns: A valid `Endpoint.Pagianted`.
    static func users<C: Collection>(_ identifiers: C) -> ManyUsers where C.Element == String {
        .init(identifiers: Array(identifiers))
    }
}

public extension Endpoint.ManyUsers {
    /// List all friendship statuses between the list of users and the logged in one.
    var friendships: Endpoint.Disposable<Swiftagram.Friendship.Dictionary, Error> {
        .init { secret, session in
            Deferred {
                Request.friendships
                    .path(appending: "show_many/")
                    .header(appending: secret.header)
                    .body(["user_ids": self.identifiers.joined(separator: ","),
                           "_csrftoken": secret["csrftoken"]!,
                           "_uuid": secret.client.device.identifier.uuidString])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Friendship.Dictionary.init)
            }
            .eraseToAnyPublisher()
        }
    }
}
