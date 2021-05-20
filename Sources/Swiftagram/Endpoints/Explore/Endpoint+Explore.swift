//
//  Endpoint+Explore.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/04/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `struct` defining `explore` endpoints.
    final class Explore { }
}

public extension Endpoint {
    /// A wrapper for explore endpoints.
    static let explore: Group.Explore = .init()
}

extension Request {
    /// A discover related request.
    static let discover = Request.version1.discover.appendingDefaultHeader()
}

public extension Endpoint.Group.Explore {
    /// A list of posts in the explore page.
    var posts: Endpoint.Paginated<Wrapper, String?, Error> {
        .init { secret, session, pages in
            Pager(pages) {
                Request.discover
                    .explore
                    .header(appending: secret.header)
                    .query(appending: $0, forKey: "max_id")
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .iterateFirst(stoppingAt: $0) {
                        $0.flatMap { $0.nextMaxId.string(converting: true) }
                            .flatMap(Instruction.load) ?? .stop
                    }
            }
            .eraseToAnyPublisher()
        }
    }

    /// A list of topics in the explore page.
    var topics: Endpoint.Paginated<Wrapper, String?, Error> {
        .init { secret, session, pages in
            Pager(pages) {
                Request.discover
                    .topical_explore
                    .header(appending: secret.header)
                    .query(appending: ["is_prefetch": "true",
                                       "omit_cover_media": "false",
                                       "use_sectional_payload": "true",
                                       "timezone_offset": "43200",
                                       "session_id": secret["sessionid"],
                                       "include_fixed_destinations": "false",
                                       "max_id": $0])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .iterateFirst(stoppingAt: $0) {
                        $0.flatMap { $0.nextMaxId.string(converting: true) }
                            .flatMap(Instruction.load) ?? .stop
                    }
            }
            .eraseToAnyPublisher()
        }
    }
}
