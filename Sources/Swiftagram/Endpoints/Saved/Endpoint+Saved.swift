//
//  Endpoint+Saved.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 19/04/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `struct` defining saved-related endpoints.
    struct Saved { }
}

public extension Endpoint {
    /// A wrapper for saved-related endpoints.
    ///
    /// - returns: A valid `Endpoint.Group.Saved`.
    static var saved: Endpoint.Group.Saved { .init() }
}

public extension Endpoint.Group.Saved {
    /// List all saved posts reguardless of their collection.
    ///
    /// - returns: A valid `Endpoint.Paginated`.
    var posts: Endpoint.Paginated<String?, Swiftagram.Media.Collection> {
        .init { secret, pages, requester in
            Receivables.Pager(pages) {
                Request.feed
                    .saved
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .query(appending: ["include_igtv_preview": "true",
                                       "show_igtv_first": "false",
                                       "max_id": $0])
                    .prepare(with: requester)
                    .map(\.data)
                    .decode()
                    .map(Swiftagram.Media.Collection.init)
            }
            .requested(by: requester)
        }
    }

    /// List all collections.
    ///
    /// - returns: A valid `Endpoint.Paginated`.
    var collections: Endpoint.Paginated<String?, SavedCollection.Collection> {
        .init { secret, pages, requester in
            let types = ["ALL_MEDIA_AUTO_COLLECTION",
                         "PRODUCT_AUTO_COLLECTION",
                         "MEDIA",
                         "AUDIO_AUTO_COLLECTION",
                         "GUIDES_AUTO_COLLECTION"]
                .map { #""\#($0)""# }
                .joined(separator: ",")
            // Return the actual publisher.
            return Receivables.Pager(pages) {
                Request.version1
                    .collections
                    .list
                    .query(appending: ["max_id": $0, "collection_types": "[\(types)]"])
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .prepare(with: requester)
                    .map(\.data)
                    .decode()
                    .map(SavedCollection.Collection.init)
            }
            .requested(by: requester)
        }
    }
}
