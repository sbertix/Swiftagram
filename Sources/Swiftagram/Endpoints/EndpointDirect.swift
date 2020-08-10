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
        public static func threads(startingAt page: String? = nil) -> Paginated<ThreadCollection> {
            return base.inbox
                .appending(query: ["visual_message_return_type": "unseen",
                                   "direction": page.flatMap { _ in "older" },
                                   "thread_message_limit": "10",
                                   "persistent_badging": "true",
                                   "limit": "20"])
                .paginating(process: ThreadCollection.self, key: "cursor", keyPath: \.oldestCursor, value: page)
                .locking(Secret.self)
        }

        /// All pending threads.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func pendingThreads(startingAt page: String? = nil) -> Paginated<ThreadCollection> {
            return base.appending(path: "pending_inbox")
                .appending(query: ["visual_message_return_type": "unseen",
                                   "direction": page.flatMap { _ in "older" },
                                   "thread_message_limit": "10",
                                   "persistent_badging": "true",
                                   "limit": "20"])
                .paginating(process: ThreadCollection.self, key: "cursor", keyPath: \.oldestCursor, value: page)
                .locking(Secret.self)
        }

        /// Top ranked recipients matching `query`.
        /// - parameter query: An optional `String`.
        public static func recipients(matching query: String? = nil) -> Disposable<ThreadRecipientCollection> {
            return base.appending(path: "ranked_recipients/")
                .appending(header: ["mode": "raven",
                                    "query": query ?? "",
                                    "show_threads": "true"])
                .prepare(process: ThreadRecipientCollection.self)
                .locking(Secret.self)
        }

        /// A thread matching `identifier`.
        /// - parameters:
        ///     - identifier: A `String` holding reference to a valid thread identifier.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func thread(matching identifier: String,
                                  startingAt page: String? = nil) -> Paginated<ThreadUnit> {
            return base.threads
                .appending(path: identifier)
                .appending(query: ["visual_message_return_type": "unseen",
                                   "direction": "older",
                                   "limit": "20"])
                .paginating(process: ThreadUnit.self, key: "cursor", keyPath: \.thread.oldestCursor, value: page)
                .locking(Secret.self)
        }

        /// Get user presence.
        public static let presence = base.appending(path: "get_presence/").prepare().locking(Secret.self)

        // MARK: Deprecated
        /// Top ranked recipients.
        @available(*, deprecated, renamed: "recipients()")
        public static let rankedRecipients: DisposableResponse = base.ranked_recipients.prepare().locking(Secret.self)
    }
}
