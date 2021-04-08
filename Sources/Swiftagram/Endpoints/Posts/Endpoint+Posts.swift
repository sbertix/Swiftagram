//
//  Endpoint+Posts.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/04/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `struct` defining posts-related endpoints.
    struct Posts { }
}

public extension Endpoint {
    /// A wrapper for posts-specific endpoints.
    static let posts: Endpoint.Group.Posts = .init()
}

public extension Endpoint.Group.Posts {
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

    /// A list of posts saved by the logged in user.
    var saved: Endpoint.Paginated<Swiftagram.Media.Collection,
                                  RankedOffset<String?, String?>,
                                  Error> {
        .init { secret, session, pages in
            // Persist the rank token.
            let rank = pages.rank ?? String(Int.random(in: 1_000..<10_000))
            // Prepare the actual pager.
            return Pager(pages) {
                Request.feed
                    .saved
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .header(appending: ["rank_token": rank,
                                        "include_igtv_preview": "false"])
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
