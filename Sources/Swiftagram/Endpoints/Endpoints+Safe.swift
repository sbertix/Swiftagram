//
//  Endpoints+Safe.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 19/04/21.
//

import Foundation

public extension Endpoints.Safe {
    /// Fetch all collections.
    static var collections: Endpoint.Loop<String?, AnyDecodable> {
        let types = ["ALL_MEDIA_AUTO_COLLECTION",
                     "PRODUCT_AUTO_COLLECTION",
                     "MEDIA",
                     "AUDIO_AUTO_COLLECTION",
                     "GUIDES_AUTO_COLLECTION"]
            .map { #""\#($0)""# }
            .joined(separator: ",")
        return .init { secret, offset in
            Loop(startingAt: offset) {
                Path("https://i.instagram.com/api/v1/collections/list")
                Headers() // Default headers.
                Headers(secret.header)
                Query(["max_id": $0, "collection_types": "[\(types)]"])
                Response(AnyDecodable.self) // SavedCollection.Collection
            } next: {
                $0.nextMaxId.string.flatMap(NextAction.advance)
            }.eraseToAnyLoopEndpoint()
        }
    }

    /// Fetch saved posts, reguardless of their collection.
    static var posts: Endpoint.Loop<String?, AnyDecodable> {
        .init { secret, offset in
            Loop(startingAt: offset) {
                Path("https://i.instagram.com/api/v1/feed/saved")
                Headers() // Default headers.
                Headers(secret.header)
                Query([
                    "include_igtv_preview": "true",
                    "show_igtv_first": "false",
                    "max_id": $0
                ])
                Response(AnyDecodable.self) // Media.Collection
            } next: {
                $0.nextMaxId.string.flatMap(NextAction.advance)
            }.eraseToAnyLoopEndpoint()
        }
    }
}
