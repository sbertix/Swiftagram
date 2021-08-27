//
//  Endpoint+Archived.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 19/04/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `struct` defining archive-related endpoints.
    struct Archived { }
}

public extension Endpoint {
    /// A wrapper for archive-related endpoints.
    static var archived: Endpoint.Group.Archived { .init() }
}

public extension Endpoint.Group.Archived {
    /// All archived posts.
    var posts: Endpoint.Paginated<String?, Swiftagram.Media.Collection> {
        .init { secret, pages, requester in
            Receivables.Pager(pages) {
                Request.feed
                    .path(appending: "only_me_feed/")
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

    /// All archived stories.
    var stories: Endpoint.Paginated<String?, TrayItem.Collection> {
        .init { secret, pages, requester in
            Receivables.Pager(pages) {
                Request.version1
                    .archive
                    .reel
                    .day_shells
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .query(appending: $0, forKey: "max_id")
                    .prepare(with: requester)
                    .map(\.data)
                    .decode()
                    .map(TrayItem.Collection.init)
            }
            .requested(by: requester)
        }
    }
}
