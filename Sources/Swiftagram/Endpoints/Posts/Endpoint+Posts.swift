//
//  Endpoint+Posts.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/04/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `class` defining posts-related endpoints.
    final class Posts { }
}

public extension Endpoint {
    /// A wrapper for posts-specific endpoints.
    static var posts: Endpoint.Group.Posts { .init() }
}

public extension Endpoint.Group.Posts {
    /// A list of archived posts.
    var archived: Endpoint.Paginated <String?, Swiftagram.Media.Collection> {
        Endpoint.archived.posts
    }

    /// The logged in user's timeline.
    var recent: Endpoint.Paginated<String?, Wrapper> {
        Endpoint.recent.posts
    }

    /// A list of all saved posts.
    ///
    /// - note: Use `Endpoint.saved` accessories to deal with specific collections.
    var saved: Endpoint.Paginated<String?, Swiftagram.Media.Collection> {
        Endpoint.saved.posts
    }

    /// A list of posts liked by the logged in user.
    var liked: Endpoint.Paginated<String?, Swiftagram.Media.Collection> {
        .init { secret, pages, requester in
            Receivables.Pager(pages) {
                Request.feed
                    .liked
                    .header(appending: secret.header)
                    .query(appending: $0, forKey: "max_id")
                    .prepare(with: requester)
                    .map(\.data)
                    .decode()
                    .map(Swiftagram.Media.Collection.init)
            }
            .requested(by: requester)
        }
    }
}
