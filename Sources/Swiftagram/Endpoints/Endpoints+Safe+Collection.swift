//
//  Endpoints+Safe+Collection.swift
//  
//
//  Created by Stefano Bertagno on 05/12/22.
//

import Foundation

/// An `enum` listing collection errors.
public enum SafeCollectionError: Swift.Error {
    /// All saved media is not a valid collection.
    /// Use `Endpoint.posts.saved.all` instead.
    case unsupportedAutoCollection
}

public extension Endpoints.Safe {
    /// A `struct` defining an instance
    /// holding reference to a specific collection.
    struct Collection: Identifiable {
        /// The collection identifier.
        public let id: String

        /// Init.
        ///
        /// - parameter id: The collection identifier.
        public init(id: ID) {
            self.id = id
        }
    }
}

public extension Endpoints.Safe.Collection {
    /// Fetch all posts inside the collection.
    var posts: Endpoint.Loop<String?, AnyDecodable> {
        .init { secret, offset in
            guard id != "ALL_MEDIA_AUTO_COLLECTION" else {
                return Static(error: SafeCollectionError.unsupportedAutoCollection)
                    .eraseToAnyLoopEndpoint()
            }
            return Loop(startingAt: offset) {
                Path("https://i.instagram.com/api/v1/feed/collection/\(id)/posts/")
                Headers() // Default headers.
                Headers(secret.header)
                Query(["max_id": $0, "include_igtv_preview": "true"])
                Response(AnyDecodable.self) // SavedCollection.Unit
            } next: {
                $0.nextMaxId.string.flatMap(NextAction.advance)
            }.eraseToAnyLoopEndpoint()
        }
    }

    /// Fetch all reels inside the collection.
    var reels: Endpoint.Loop<String?, AnyDecodable> {
        .init { secret, offset in
            guard id != "ALL_MEDIA_AUTO_COLLECTION" else {
                return Static(error: SafeCollectionError.unsupportedAutoCollection)
                    .eraseToAnyLoopEndpoint()
            }
            return Loop(startingAt: offset) {
                Path("https://i.instagram.com/api/v1/feed/collection/\(id)/igtv/")
                Headers() // Default headers.
                Headers(secret.header)
                Query(["max_id": $0, "id": "collection_\(id)"])
                Response(AnyDecodable.self) // SavedCollection.Unit
            } next: {
                $0.nextMaxId.string.flatMap(NextAction.advance)
            }.eraseToAnyLoopEndpoint()
        }
    }
}
