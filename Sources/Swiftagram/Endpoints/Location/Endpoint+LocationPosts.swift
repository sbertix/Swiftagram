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
    var recent: Endpoint.Paginated<Section.Page?, Section.Collection> {
        .init { secret, pages, requester -> R.Requested<Section.Collection> in
            Receivables.Pager(pages) { page -> R.Requested<Section.Collection> in
                Request.location(self.location.identifier)
                    .sections
                    .path(appending: "/")
                    .header(appending: secret.header)
                    .body(appending: ["max_id": page?.identifier,
                                      "tab": "recent",
                                      "page": (page?.page).flatMap { $0 <= 0 ? nil : "\($0)" },
                                      "next_media_ids": "[\(page?.mediaIdentifiers.joined(separator: ",") ?? "")]",
                                      "_csrftoken": secret["csrftoken"],
                                      "_uuid": secret.client.device.identifier.uuidString,
                                      "session_id": secret["sessionid"]].compactMapValues { $0 })
                    .prepare(with: requester)
                    .map(\.data)
                    .decode()
                    .map(Section.Collection.init)
                    .requested(by: requester)
            }
            .requested(by: requester)
        }
    }

    /// A list of highest ranking posts.
    var top: Endpoint.Paginated<Section.Page?, Section.Collection> {
        .init { secret, pages, requester -> R.Requested<Section.Collection> in
            Receivables.Pager(pages) { page -> R.Requested<Section.Collection> in
                Request.location(self.location.identifier)
                    .sections
                    .path(appending: "/")
                    .header(appending: secret.header)
                    .body(appending: ["max_id": page?.identifier,
                                      "tab": "ranked",
                                      "page": (page?.page).flatMap { $0 <= 0 ? nil : "\($0)" },
                                      "next_media_ids": "[\(page?.mediaIdentifiers.joined(separator: ",") ?? "")]",
                                      "_csrftoken": secret["csrftoken"],
                                      "_uuid": secret.client.device.identifier.uuidString,
                                      "session_id": secret["sessionid"]].compactMapValues { $0 })
                    .prepare(with: requester)
                    .map(\.data)
                    .decode()
                    .map(Section.Collection.init)
                    .requested(by: requester)
            }
            .requested(by: requester)
        }
    }
}
