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
    static let saved: Endpoint.Group.Saved = .init()
}

public extension Endpoint.Group.Saved {
    /// List all saved posts reguardless of their collection.
    ///
    /// - returns: A valid `Endpoint.Paginated`.
    var posts: Endpoint.Paginated<Swiftagram.Media.Collection, String?, Error> {
        .init { secret, session, pages in
            Pager(pages) {
                Request.feed
                    .saved
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .query(appending: ["include_igtv_preview": "true",
                                       "show_igtv_first": "false",
                                       "max_id": $0])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Media.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .replaceFailingWithError()
        }
    }

    /// List all collections.
    ///
    /// - returns: A valid `Endpoint.Paginated`.
    var collections: Endpoint.Paginated<SavedCollection.Collection, String?, Error> {
        .init { secret, session, pages in
            let types = ["ALL_MEDIA_AUTO_COLLECTION",
                         "PRODUCT_AUTO_COLLECTION",
                         "MEDIA",
                         "AUDIO_AUTO_COLLECTION",
                         "GUIDES_AUTO_COLLECTION"]
                .map { #""\#($0)""# }
                .joined(separator: ",")
            // Return the actual publisher.
            return Pager(pages) {
                Request.version1
                    .collections
                    .list
                    .query(appending: ["max_id": $0, "collection_types": "[\(types)]"])
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(SavedCollection.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .replaceFailingWithError()
        }
    }
}
