//
//  Endpoint+Tag.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/04/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `struct` defining tag endpoints.
    struct Tag {
        /// The tag name.
        public let name: String
    }
}

public extension Endpoint {
    /// A wrapper for tag-specific endpoints.
    ///
    /// - parameter name: A valid `String`.
    /// - returns: A valid `Tag`.
    static func tag(_ name: String) -> Group.Tag {
        .init(name: name)
    }
}

public extension Endpoint.Group.Tag {
    /// A list of recent posts tagged with name.
    var posts: Endpoint.Paginated<Swiftagram.Media.Collection,
                                  RankedOffset<String?, String?>,
                                  Error> {
        .init { secret, session, pages in
            // Persist the rank token.
            let rank = pages.rank ?? String(Int.random(in: 1_000..<10_000))
            // Prepare the actual pager.
            return Pager(pages) {
                Request.feed
                    .tag
                    .path(appending: self.name)
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
