//
//  Endpoint+Archive.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/04/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `struct` defining `archive` endpoints.
    struct Archive { }
}

public extension Endpoint {
    /// A wrapper for archive endpoints.
    static let archive: Group.Archive = .init()
}

public extension Endpoint.Group.Archive {
    /// All archived posts.
    var posts: Endpoint.Paginated<Swiftagram.Media.Collection,
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

    /// All archived stories.
    var stories: Endpoint.Paginated<TrayItem.Collection,
                                    RankedOffset<String?, String?>,
                                    Error> {
        .init { secret, session, pages in
            // Persist the rank token.
            let rank = pages.rank ?? String(Int.random(in: 1_000..<10_000))
            // Prepare the actual pager.
            return Pager(pages) {
                Request.version1
                    .archive
                    .reel
                    .day_shells
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .header(appending: rank, forKey: "rank_token")
                    .query(appending: $0, forKey: "max_id")
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(TrayItem.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .eraseToAnyPublisher()
        }
    }
}
