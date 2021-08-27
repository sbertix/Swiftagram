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

    /// An `enum` listing all possible muting actions.
    enum Muting: Equatable {
        /// Posts and stories.
        case all
        /// Posts.
        case posts
        /// Stories.
        case stories
    }

    /// A wrapper for request endpoints.
    var request: Request {
        .init(user: self)
    }

    /// Block the given user.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func block() -> Endpoint.Single<Friendship.Unit> {
        edit("block")
    }

    /// Follow the given user.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func follow() -> Endpoint.Single<Friendship.Unit> {
        edit("create")
    }

    /// Mute the given user.
    ///
    /// - parameter action: A valid `Muting`.
    /// - returns: A valid `Endpoint.Single`.
    func mute(_ action: Muting) -> Endpoint.Single<Friendship.Unit> {
        .init { secret, requester in
            Swiftagram.Request.version1
                .friendships
                .path(appending: "mute_posts_or_story_from_follow/")
                .appendingDefaultHeader()
                .header(appending: secret.header)
                .signing(body: ["_csrftoken": secret["csrftoken"],
                                "_uid": secret.identifier,
                                "_uuid": secret.client.device.identifier.uuidString,
                                "container_module": "feed_timeline",
                                "target_reel_author_id": action != .posts ? self.identifier : nil,
                                "target_posts_author_id": action != .stories ? self.identifier : nil]
                            .compactMapValues { $0 })
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Friendship.Unit.init)
                .requested(by: requester)
        }
    }

    /// Remove the given user from your followers.
    ///
    /// - returns: A valid `Endpoint.Single`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func remove() -> Endpoint.Single<Friendship.Unit> {
        edit("remove_follower")
    }

    /// Unblock the given user.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unblock() -> Endpoint.Single<Friendship.Unit> {
        edit("unblock")
    }

    /// Unfollow the given user.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unfollow() -> Endpoint.Single<Friendship.Unit> {
        edit("destroy")
    }

    /// Unmute the given user.
    ///
    /// - parameter action: A valid `Muting`.
    /// - returns: A valid `Endpoint.Single`.
    func unmute(_ action: Muting) -> Endpoint.Single<Friendship.Unit> {
        .init { secret, requester in
            Swiftagram.Request.version1
                .friendships
                .path(appending: "unmute_posts_or_story_from_follow/")
                .appendingDefaultHeader()
                .header(appending: secret.header)
                .signing(body: ["_csrftoken": secret["csrftoken"],
                                "_uid": secret.identifier,
                                "_uuid": secret.client.device.identifier.uuidString,
                                "container_module": "feed_timeline",
                                "target_reel_author_id": action != .posts ? self.identifier : nil,
                                "target_posts_author_id": action != .stories ? self.identifier : nil]
                            .compactMapValues { $0 })
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Friendship.Unit.init)
                .requested(by: requester)
        }
    }
}

public extension Endpoint.Group.User.Request {
    /// Accept the follow request.
    ///
    /// - returns: A valid `Endpoint.Single`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func approve() -> Endpoint.Single<Friendship.Unit> {
        user.edit("approve")
    }

    /// Decline the follow request.
    ///
    /// - returns: A valid `Endpoint.Single`.
    /// - warning: This is not tested in `SwiftagramTests`, so it might not work in the future. Open an `issue` if that happens.
    func decline() -> Endpoint.Single<Friendship.Unit> {
        user.edit("decline")
    }
}

fileprivate extension Endpoint.Group.User {
    /// Perform an action involving the user matching `identifier`.
    ///
    /// - parameter endpoint: A valid `String`.
    /// - note: **SwiftagramCrypto** only.
    func edit(_ endpoint: String) -> Endpoint.Single<Friendship.Unit> {
        .init { secret, requester in
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
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Friendship.Unit.init)
                .requested(by: requester)
        }
    }
}
