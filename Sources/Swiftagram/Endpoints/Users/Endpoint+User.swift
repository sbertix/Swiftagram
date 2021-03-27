//
//  Endpoint+User.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/03/21.
//

import Foundation

public extension Endpoint {
    /// A `struct` defining user-related endpoints.
    struct User {
        /// The user identifier.
        public let identifier: String
    }

    /// A wrapper for user endpoints.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `User`.
    static func user(_ identifier: String) -> User {
        .init(identifier: identifier)
    }

    /// A summary for a given user.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Endpoint.Disposable`.
    static func user(_ identifier: String) -> Endpoint.Disposable<Swiftagram.User.Unit, Error> {
        user(identifier).summary
    }

    /// A summary for a user which username exactly matches the one provided.
    ///
    /// - parameter username: A valid `String`.
    /// - returns: A valid `Endpoint.Disposable`.
    static func user(matching username: String) -> Endpoint.Disposable<Swiftagram.User.Unit, Error> {
        .init { secret, session in
            Deferred {
                Request.users
                    .path(appending: username)
                    .path(appending: "usernameinfo/")
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.User.Unit.init)
            }
            .eraseToAnyPublisher()
        }
    }
}

extension Request {
    /// A specific discover based request.
    static let discover = Endpoint.version1.discover.appendingDefaultHeader()

    /// A specific friendship based reqeust.
    static let friendships = Endpoint.version1.friendships.appendingDefaultHeader()

    /// A specific users based request.
    static let users = Endpoint.version1.users.appendingDefaultHeader()

    /// A specic friendship based request.
    ///
    /// - parameter user: A valid `User`.
    /// - returns: A valid `Request`.
    static func friendship(_ user: Endpoint.User) -> Request {
        friendships.path(appending: user.identifier)
    }

    /// A specific user based request.
    ///
    /// - parameter user: A valid `User`.
    /// - returns: A valid `Request`.
    static func user(_ user: Endpoint.User) -> Request {
        users.path(appending: user.identifier)
    }
}

public extension Endpoint.User {
    /// A summary for the current user.
    ///
    /// - note: Use `Endpoint.user(_:)` instead.
    internal var summary: Endpoint.Disposable<Swiftagram.User.Unit, Error> {
        .init { secret, session in
            Deferred {
                Request.user(self)
                    .info
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.User.Unit.init)
            }
            .eraseToAnyPublisher()
        }
    }

    /// A list of profiles following the user.
    var followers: Endpoint.Paginated<Swiftagram.User.Collection, RankedOffset<String?, String?>, Error> {
        paginated("followers", matching: nil)
    }

    /// A list of profiles followed by the user.
    var following: Endpoint.Paginated<Swiftagram.User.Collection, RankedOffset<String?, String?>, Error> {
        paginated("following", matching: nil)
    }

    /// The current friendship status between the given user and the logged in one.
    var friendship: Endpoint.Disposable<Swiftagram.Friendship, Error> {
        .init { secret, session in
            Deferred {
                Request.friendships
                    .show
                    .path(appending: self.identifier)
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Friendship.init)
            }
            .eraseToAnyPublisher()
        }
    }

    /// A list of similar/suggested users.
    var similar: Endpoint.Disposable<Swiftagram.User.Collection, Error> {
        .init { secret, session in
            Deferred {
                Request.discover
                    .chaining
                    .query(appending: self.identifier, forKey: "target_id")
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.User.Collection.init)
            }
            .eraseToAnyPublisher()
        }
    }

    /// A list of profiles following the user.
    ///
    /// - parameter query: A valid `String`.
    /// - returns: A valid `Endpoint.Paginated`.
    func followers(matching query: String) -> Endpoint.Paginated<Swiftagram.User.Collection, RankedOffset<String?, String?>, Error> {
        paginated("followers", matching: query)
    }

    /// A list of profiles followed by the user.
    ///
    /// - parameter query: A valid `String`.
    /// - returns: A valid `Endpoint.Paginated`.
    func following(matching query: String) -> Endpoint.Paginated<Swiftagram.User.Collection, RankedOffset<String?, String?>, Error> {
        paginated("following", matching: query)
    }
}

fileprivate extension Endpoint.User {
    /// A list of profiles following/followed by the user.
    ///
    /// - parameters:
    ///     - endpoint: A valid `String`.
    ///     - query: An optional `String`.
    /// - returns: A valid `Endpoint.Paginated`.
    func paginated(_ endpoint: String,
                   matching query: String?) -> Endpoint.Paginated<Swiftagram.User.Collection, RankedOffset<String?, String?>, Error> {
        .init { secret, session, pages in
            // Persist the rank token.
            let rank = pages.rank ?? String(Int.random(in: 1_000..<10_000))
            // Prepare the actual pager.
            return Pager(pages) {
                Request.friendship(self)
                    .path(appending: endpoint)
                    .header(appending: secret.header)
                    .header(appending: rank, forKey: "rank_token")
                    .query(appending: ["q": query, "max_id": $0])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.User.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .eraseToAnyPublisher()
        }
    }
}
