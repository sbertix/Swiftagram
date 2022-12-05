//
//  Endpoints+Archive.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 05/12/22.
//

import Foundation

public extension Endpoints.Archives {
    /// Fetch all archived posts.
    static var posts: Endpoint.Loop<String?, AnyDecodable> {
        .init { secret, offset in
            Loop(startingAt: offset) {
                Path("https://i.instagram.com/api/v1/feed/only_meed_feed/")
                Headers() // Default headers.
                Headers(secret.header)
                Query($0, forKey: "max_id")
                Response(AnyDecodable.self) // Media.Collection
            } next: {
                $0.nextMaxId.string.flatMap(NextAction.advance)
            }.eraseToAnyLoopEndpoint()
        }
    }

    /// Fetch all archived stories.
    static var stories: Endpoint.Loop<String?, AnyDecodable> {
        .init { secret, offset in
            Loop(startingAt: offset) {
                Path("https://i.instagram.com/api/v1/archive/reel/day_shells")
                Headers() // Default headers.
                Headers(secret.header)
                Query($0, forKey: "max_id")
                Response(AnyDecodable.self) // TrayItem.Collection
            } next: {
                $0.nextMaxId.string.flatMap(NextAction.advance)
            }.eraseToAnyLoopEndpoint()
        }
    }
}
