//
//  EndpointDirect.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A `struct` holding reference to `direct_v2` `Endpoint`s. Requires authentication.
    struct Direct {
        /// The base endpoint.
        private static let base = Endpoint.version1.direct_v2.appendingDefaultHeader()

        /// All threads.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func inbox(startingAt page: String? = nil) -> Paginated<Conversation.Collection> {
            return base.inbox
                .appending(query: ["visual_message_return_type": "unseen",
                                   "direction": page.flatMap { _ in "older" },
                                   "thread_message_limit": "10",
                                   "persistent_badging": "true",
                                   "limit": "20"])
                .paginating(process: Conversation.Collection.self, key: "cursor", keyPath: \.oldestCursor, value: page)
                .locking(Secret.self)
        }

        /// All pending threads.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func pendingInbox(startingAt page: String? = nil) -> Paginated<Conversation.Collection> {
            return base.appending(path: "pending_inbox")
                .appending(query: ["visual_message_return_type": "unseen",
                                   "direction": page.flatMap { _ in "older" },
                                   "thread_message_limit": "10",
                                   "persistent_badging": "true",
                                   "limit": "20"])
                .paginating(process: Conversation.Collection.self, key: "cursor", keyPath: \.oldestCursor, value: page)
                .locking(Secret.self)
        }

        /// Top ranked recipients matching `query`.
        /// - parameter query: An optional `String`.
        public static func recipients(matching query: String? = nil) -> Disposable<Recipient.Collection> {
            return base.appending(path: "ranked_recipients/")
                .appending(header: ["mode": "raven",
                                    "query": query ?? "",
                                    "show_threads": "true"])
                .prepare(process: Recipient.Collection.self)
                .locking(Secret.self)
        }

        /// A thread matching `identifier`.
        /// - parameters:
        ///     - identifier: A `String` holding reference to a valid thread identifier.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func conversation(matching identifier: String,
                                        startingAt page: String? = nil) -> Paginated<Conversation.Unit> {
            return base.threads
                .appending(path: identifier)
                .appending(query: ["visual_message_return_type": "unseen",
                                   "direction": "older",
                                   "limit": "20"])
                .paginating(process: Conversation.Unit.self, key: "cursor", keyPath: \.thread.oldestCursor, value: page)
                .locking(Secret.self)
        }

        /// Get user presence.
        public static let presence: Disposable<Wrapper> = base.appending(path: "get_presence/").prepare().locking(Secret.self)
    }
}
