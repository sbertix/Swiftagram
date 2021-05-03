//
//  Endpoint+User.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/03/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `class` defining user-related endpoints.
    final class User {
        /// The user identifier.
        public let identifier: String

        /// Init.
        ///
        /// - parameter identifier: A valid `String`.
        init(identifier: String) {
            self.identifier = identifier
        }
    }
}

public extension Endpoint {
    /// A wrapper for user endpoints.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `EndpointUser`.
    static func user(_ identifier: String) -> Group.User {
        .init(identifier: identifier)
    }

    /// A wrapper for user endpoints.
    ///
    /// - parameter user: A valid `User`.
    /// - returns: A valid `Endpoint.User`.
    static func user(_ user: Swiftagram.User) -> Group.User {
        self.user(user.identifier)
    }

    /// A summary for a given user.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    static func user(_ identifier: String) -> Endpoint.Single<Swiftagram.User.Unit, Error> {
        user(identifier).summary
    }

    /// A summary for a user which username exactly matches the one provided.
    ///
    /// - parameter username: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    static func user(matching username: String) -> Endpoint.Single<Swiftagram.User.Unit, Error> {
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
    /// A specific friendship based reqeust.
    static let friendships = Request.version1.friendships.appendingDefaultHeader()

    /// A specific users based request.
    static let users = Request.version1.users.appendingDefaultHeader()

    /// A specic friendship based request.
    ///
    /// - parameter user: A valid `User`.
    /// - returns: A valid `Request`.
    static func friendship(_ user: Endpoint.Group.User) -> Request {
        friendships.path(appending: user.identifier)
    }

    /// A specific user based request.
    ///
    /// - parameter user: A valid `User`.
    /// - returns: A valid `Request`.
    static func user(_ user: Endpoint.Group.User) -> Request {
        users.path(appending: user.identifier)
    }
}

public extension Endpoint.Group.User {
    /// A summary for the current user.
    ///
    /// - note: Prefer `Endpoint.user(_:)` instead.
    var summary: Endpoint.Single<Swiftagram.User.Unit, Error> {
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
            .replaceFailingWithError()
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
    var friendship: Endpoint.Single<Swiftagram.Friendship, Error> {
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

    /// A list of highlights uploaded by the user.
    var higlights: Endpoint.Single<TrayItem.Collection, Error> {
        .init { secret, session in
            Deferred {
                Request.version1.highlights
                    .path(appending: self.identifier)
                    .highlights_tray
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .query(appending: [
                        "supported_capabilities_new": try? SupportedCapabilities
                            .default
                            .map { ["name": $0.key, "value": $0.value] }
                            .wrapped
                            .jsonRepresentation(),
                        "phone_id": secret.client.device.phoneIdentifier.uuidString,
                        "battery_level": "72",
                        "is_charging": "0",
                        "will_sound_on": "0"
                    ])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(TrayItem.Collection.init)
            }
            .replaceFailingWithError()
        }
    }

    /// A list of posts uploaded by the user.
    var posts: Endpoint.Paginated<Swiftagram.Media.Collection,
                                  String?,
                                  Error> {
        .init { secret, session, pages in
            Pager(pages) {
                Request.version1.feed
                    .user
                    .path(appending: self.identifier)
                    .header(appending: secret.header)
                    .query(appending: ["exclude_comment": "false",
                                       "only_fetch_first_carousel_media": "false"])
                    .query(appending: $0, forKey: "max_id")
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Media.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .replaceFailingWithError()
        }
    }

    /// A list of similar/suggested users.
    var similar: Endpoint.Single<Swiftagram.User.Collection, Error> {
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
            .replaceFailingWithError()
        }
    }

    /// A list of all recent stories by the user.
    var stories: Endpoint.Single<TrayItem.Unit, Error> {
        .init { secret, session in
            Deferred {
                Request.version1
                    .feed
                    .user
                    .path(appending: self.identifier)
                    .reel_media
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(TrayItem.Unit.init)
            }
            .replaceFailingWithError()
        }
    }

    /// A list of posts the user was tagged in.
    var tags: Endpoint.Paginated<Swiftagram.Media.Collection,
                                 RankedOffset<String?, String?>,
                                 Error> {
        .init { secret, session, pages in
            // Persist the rank token.
            let rank = pages.rank ?? String(Int.random(in: 1_000..<10_000))
            // Prepare the actual pager.
            return Pager(pages) {
                Request.version1
                    .usertags
                    .path(appending: self.identifier)
                    .feed
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .header(appending: rank, forKey: "rank_token")
                    .query(appending: $0, forKey: "max_id")
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Media.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .replaceFailingWithError()
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

fileprivate extension Endpoint.Group.User {
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
            .replaceFailingWithError()
        }
    }
}
