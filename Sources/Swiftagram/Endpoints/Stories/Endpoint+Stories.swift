//
//  Endpoint+Stories.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/04/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `class` defining stories-related endpoints.
    final class Stories { }
}

public extension Endpoint {
    /// A wrapper for stories-specific endpoints.
    static let stories: Endpoint.Group.Stories = .init()

    /// An endpoint for loading specific endpoints.
    ///
    /// - parameter identifiers: A collection of `String`s.
    /// - returns: A valid `Endpoint.Single`.
    static func stories<C: Collection>(_ identifiers: C) -> Endpoint.Single<TrayItem.Dictionary, Error> where C.Element == String {
        users(identifiers).stories
    }
}

public extension Endpoint.Group.Stories {
    /// All archived stories.
    var archived: Endpoint.Paginated<TrayItem.Collection,
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
