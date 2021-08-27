//
//  Endpoint+TagPosts.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 19/04/21.
//

import Foundation

public extension Endpoint.Group.Tag {
    /// A `struct` defining tag-related posts endpoints.
    struct Posts {
        /// The underlying tag.
        public let tag: Endpoint.Group.Tag

        /// Init.
        ///
        /// - parameter tag: A valid `Tag`.
        init(tag: Endpoint.Group.Tag) {
            self.tag = tag
        }
    }

    /// A wrapper for tag-related posts edpoints.
    var posts: Posts {
        .init(tag: self)
    }
}

public extension Endpoint.Group.Tag.Posts {
    /// A list of recent posts.
    var recent: Endpoint.Paginated<Section.Page?, Section.Collection> {
        .init { secret, pages, requester -> R.Requested<Section.Collection> in
            Receivables.Pager(pages) { page -> R.Requested<Section.Collection> in
                Request.tag(self.tag.name)
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
                Request.tag(self.tag.name)
                    .sections
                    .path(appending: "/")
                    .header(appending: secret.header)
                    .body(appending: ["max_id": page?.identifier,
                                      "tab": "top",
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
