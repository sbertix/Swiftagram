//
//  Endpoints+Explore.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/04/21.
//

import Foundation

public extension Endpoints.Explore {
    /// Fetch all topics in the explore page.
    static var topics: Endpoint.Loop<String?, AnyDecodable> {
        .init { secret, offset in
            Loop(startingAt: offset) {
                Path("https://i.instagram.com/api/v1/topical_explore")
                Headers() // Default headers.
                Headers(secret.header)
                Query(
                    ["is_prefetch": "true",
                     "omit_cover_media": "false",
                     "use_sectional_payload": "true",
                     "timezone_offset": "43200",
                     "session_id": secret["sessionid"],
                     "include_fixed_destinations": "false",
                     "max_id": $0
                    ]
                )
                Response(AnyDecodable.self)
            } next: {
                $0.nextMaxId.string.flatMap(NextAction.advance)
            }.eraseToAnyLoopEndpoint()
        }
    }
}
