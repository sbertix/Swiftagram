//
//  Endpoint+LocationPosts.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 19/04/21.
//

import Foundation

public extension Endpoint.Group.Location {
    /// A `struct` defining location-related posts endpoints.
    struct Posts {
        /// The underlying location.
        public let location: Endpoint.Group.Location

        /// Init.
        ///
        /// - parameter location: A valid `Location`.
        init(location: Endpoint.Group.Location) {
            self.location = location
        }
    }

    /// A wrapper for location-related posts endpoints.
    var posts: Posts {
        .init(location: self)
    }
}

public extension Endpoint.Group.Location.Posts {
    /// A list of recent posts.
    var recent: Endpoint.Paginated<Section.Collection, Section.Offset?, Error> {
        .init { secret, session, pages in
            Pager(pages) {
                Request.location(self.location)
                    .sections
                    .path(appending: "/")
                    .header(appending: secret.header)
                    .body(appending: ["max_id": $0?.identifier,
                                      "tab": "recent",
                                      "page": ($0?.page).flatMap { $0 <= 0 ? nil : "\($0)" },
                                      "next_media_ids": "[\($0?.mediaIdentifiers.joined(separator: ",") ?? "")]",
                                      "_csrftoken": secret["csrftoken"],
                                      "_uuid": secret.client.device.identifier.uuidString,
                                      "session_id": secret["sessionid"]].compactMapValues { $0 })
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Section.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .eraseToAnyPublisher()
        }
    }

    /// A list of highest ranking posts.
    var top: Endpoint.Paginated<Section.Collection, Section.Offset?, Error> {
        .init { secret, session, pages in
            Pager(pages) {
                Request.location(self.location)
                    .sections
                    .path(appending: "/")
                    .header(appending: secret.header)
                    .body(appending: ["max_id": $0?.identifier,
                                      "tab": "ranked",
                                      "page": ($0?.page).flatMap { $0 <= 0 ? nil : "\($0)" },
                                      "next_media_ids": "[\($0?.mediaIdentifiers.joined(separator: ",") ?? "")]",
                                      "_csrftoken": secret["csrftoken"],
                                      "_uuid": secret.client.device.identifier.uuidString,
                                      "session_id": secret["sessionid"]].compactMapValues { $0 })
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Section.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .eraseToAnyPublisher()
        }
    }
}
