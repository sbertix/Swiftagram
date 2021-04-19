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
    static let posts: Endpoint.Group.Posts = .init()
}

public extension Endpoint.Group.Posts {
    /// All archived posts.
    var archived: Endpoint.Paginated<Swiftagram.Media.Collection,
                                     RankedOffset<String?, String?>,
                                     Error> {
        .init { secret, session, pages in
            // Persist the rank token.
            let rank = pages.rank ?? String(Int.random(in: 1_000..<10_000))
            // Prepare the actual pager.
            return Pager(pages) {
                Request.feed
                    .path(appending: "only_me_feed/")
                    .header(appending: secret.header)
                    .header(appending: rank, forKey: "rank_token")
                    .query(appending: $0, forKey: "max_id")
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Media.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .eraseToAnyPublisher()
        }
    }

    /// A list of posts liked by the logged in user.
    var liked: Endpoint.Paginated<Swiftagram.Media.Collection,
                                  RankedOffset<String?, String?>,
                                  Error> {
        .init { secret, session, pages in
            // Persist the rank token.
            let rank = pages.rank ?? String(Int.random(in: 1_000..<10_000))
            // Prepare the actual pager.
            return Pager(pages) {
                Request.feed
                    .liked
                    .header(appending: secret.header)
                    .header(appending: rank, forKey: "rank_token")
                    .query(appending: $0, forKey: "max_id")
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Media.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .eraseToAnyPublisher()
        }
    }
}
