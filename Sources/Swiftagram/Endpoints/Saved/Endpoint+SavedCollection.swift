//
//  Endpoint+SavedCollection.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 19/04/21.
//

import Foundation

public extension Endpoint.Group.Saved {
    /// A `struct` defining collection-related endpoints.
    struct Collection {
        /// The collection identifier.
        public let identifier: String
    }

    /// A wrapper for collection-related endpoints.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Collection`.
    func collection(_ identifier: String) -> Collection {
        .init(identifier: identifier)
    }

    /// A wrapper for collection-related endpoints.
    ///
    /// - parameter collection: A valid `SavedCollection`.
    /// - returns: A valid `Collection`.
    func collection(_ collection: SavedCollection) -> Collection {
        self.collection(collection.identifier)
    }

    /// An endpoint listing all posts inside a collection.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Endpoint.Paginated`.
    func collection(_ identifier: String) -> Endpoint.Paginated<SavedCollection.Unit, String?, Swift.Error> {
        collection(identifier).summary
    }

    /// An endpoint listing all posts inside a collection.
    ///
    /// - parameter collection: A valid `SavedCollection`.
    /// - returns: A valid `Endpoint.Paginated`.
    func collection(_ collection: SavedCollection) -> Endpoint.Paginated<SavedCollection.Unit, String?, Swift.Error> {
        self.collection(collection).summary
    }
}

public extension Endpoint.Group.Saved.Collection {
    /// An `enum` listing collection errors.
    enum Error: Swift.Error {
        /// All saved media is not a valid collection.
        /// Use `Endpoint.posts.saved.all` instead.
        case unsupportedAllMediaAutoCollection
    }
}

public extension Endpoint.Group.Saved.Collection {
    /// A summary of the collection.
    ///
    /// - note: Prefer `Endpoint.posts.saved.collection(_:)`.
    var summary: Endpoint.Paginated<SavedCollection.Unit, String?, Swift.Error> {
        .init { secret, session, pages in
            // Only actual collection can be fetched.
            // `ALL_MEDIA_AUTO_COLLECTION` is not supported.
            guard self.identifier != "ALL_MEDIA_AUTO_COLLECTION" else {
                return Fail(error: Error.unsupportedAllMediaAutoCollection).eraseToAnyPublisher()
            }
            return Pager(pages) {
                Request.feed
                    .collection
                    .path(appending: self.identifier)
                    .path(appending: "all/")
                    .query(appending: ["include_igtv_preview": "true",
                                       "show_igtv_first": "false",
                                       "max_id": $0])
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(SavedCollection.Unit.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .replaceFailingWithError()
        }
    }
  
    /// All posts inside the collection.
    ///
    var posts: Endpoint.Paginated<SavedCollection.Unit, String?, Swift.Error> {
        .init { secret, session, pages in
            // Only actual collection can be fetched.
            // `ALL_MEDIA_AUTO_COLLECTION` is not supported.
            guard self.identifier != "ALL_MEDIA_AUTO_COLLECTION" else {
                return Fail(error: Error.unsupportedAllMediaAutoCollection).eraseToAnyPublisher()
            }
            return Pager(pages) {
                Request.feed
                    .collection
                    .path(appending: self.identifier)
                    .path(appending: "posts/")
                    .query(appending: ["include_igtv_preview": "true",
                                       "max_id": $0])
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(SavedCollection.Unit.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .replaceFailingWithError()
        }
    }
 
    /// All igtv inside the collection.
    ///
    var igtv: Endpoint.Paginated<SavedCollection.Unit, String?, Swift.Error> {
        .init { secret, session, pages in
            // Only actual collection can be fetched.
            // `ALL_MEDIA_AUTO_COLLECTION` is not supported.
            guard self.identifier != "ALL_MEDIA_AUTO_COLLECTION" else {
                return Fail(error: Error.unsupportedAllMediaAutoCollection).eraseToAnyPublisher()
            }
            return Pager(pages) {
                Request.feed
                    .collection
                    .path(appending: self.identifier)
                    .path(appending: "igtv/")
                    .query(appending: ["id": "collection_\(self.identifier)",
                                       "max_id": $0])
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(SavedCollection.Unit.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .replaceFailingWithError()
        }
    }
}
