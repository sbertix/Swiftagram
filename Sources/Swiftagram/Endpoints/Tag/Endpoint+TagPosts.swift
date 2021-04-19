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
    var recent: Endpoint.Paginated<Section.Collection, Section.Offset?, Error> {
        .init { secret, session, pages in
            Pager(pages) {
                Request.tag(self.tag)
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
                Request.tag(self.tag)
                    .sections
                    .path(appending: "/")
                    .header(appending: secret.header)
                    .body(appending: ["max_id": $0?.identifier,
                                      "tab": "top",
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
