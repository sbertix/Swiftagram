//
//  Endpoint+Users.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/03/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `class` defining users-related endpoints.
    final class Users { }
}

public extension Endpoint {
    /// A wrapper for users endpoints.
    static var users: Group.Users { .init() }

    /// All user matching `query`.
    ///
    /// - parameter query: A `String` holding reference to a valid user query.
    /// - returns: A valid `Endpoint.Pagianted`.
    static func users(matching query: String) -> Endpoint.Paginated<String?, Swiftagram.User.Collection> {
        .init { secret, pages, requester in
            // Persist the rank token.
            let rank = UUID().uuidString
            // Prepare the actual pager.
            return Receivables.Pager(pages) {
                Request.users
                    .search
                    .header(appending: secret.header)
                    .header(appending: rank, forKey: "rank_token")
                    .query(appending: ["q": query, "max_id": $0])
                    .prepare(with: requester)
                    .map(\.data)
                    .decode()
                    .map(Swiftagram.User.Collection.init)
            }
            .requested(by: requester)
        }
    }
}

public extension Endpoint.Group.Users {
    /// A list of all profiles blocked by the logged in user.
    var blocked: Endpoint.Single<Wrapper> {
        .init { secret, requester in
            Request.users
                .blocked_list
                .header(appending: secret.header)
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .requested(by: requester)
        }
    }

    /// A list of users who requested to follow you.
    var requests: Endpoint.Paginated<String?, Swiftagram.User.Collection> {
        .init { secret, pages, requester in
            Receivables.Pager(pages) {
                Request.friendships
                    .pending
                    .header(appending: secret.header)
                    .query(appending: $0, forKey: "max_id")
                    .prepare(with: requester)
                    .map(\.data)
                    .decode()
                    .map(Swiftagram.User.Collection.init)
            }
            .requested(by: requester)
        }
    }
}
