//
//  EndpointDirect.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A module-like `enum` holding reference to `direct_v2` `Endpoint`s. Requires authentication.
    enum Direct {
        /// The base endpoint.
        private static let base = Endpoint.version1.direct_v2.appendingDefaultHeader()

        /// Fetch all threads.
        public static var inbox: Paginated<Conversation.Collection, String?, Error> {
            .init { secret, session, pages in
                Pager(pages) {
                    base.inbox
                        .header(appending: secret.header)
                        .query(appending: ["visual_message_return_type": "unseen",
                                           "direction": $0.flatMap { _ in "older" },
                                           "cursor": $0,
                                           "thread_message_limit": "10",
                                           "persistent_badging": "true",
                                           "limit": "20"])
                        .publish(with: session)
                        .map(\.data)
                        .wrap()
                        .map(Conversation.Collection.init)
                        .iterateFirst(stoppingAt: $0)
                }
                .eraseToAnyPublisher()
            }
        }

        /// All pending threads.
        public static var pendingInbox: Paginated<Conversation.Collection, String?, Error> {
            .init { secret, session, pages in
                Pager(pages) {
                    base.path(appending: "pending_inbox")
                        .header(appending: secret.header)
                        .query(appending: ["visual_message_return_type": "unseen",
                                           "direction": $0.flatMap { _ in "older" },
                                           "cursor": $0,
                                           "thread_message_limit": "10",
                                           "persistent_badging": "true",
                                           "limit": "20"])
                        .publish(with: session)
                        .map(\.data)
                        .wrap()
                        .map(Conversation.Collection.init)
                        .iterateFirst(stoppingAt: $0)
                }
                .eraseToAnyPublisher()
            }
        }

        /// Top ranked recipients matching `query`.
        ///
        /// - parameter query: An optional `String`.
        public static func recipients(matching query: String? = nil) -> Disposable<Recipient.Collection, Error> {
            .init { secret, session in
                Deferred {
                    base.path(appending: "ranked_recipients/")
                        .header(appending: secret.header)
                        .header(appending: ["mode": "raven",
                                            "query": query,
                                            "show_threads": "true"])
                        .publish(with: session)
                        .map(\.data)
                        .wrap()
                        .map(Recipient.Collection.init)
                }
                .eraseToAnyPublisher()
            }
        }

        /// A thread matching `identifier`.
        /// 
        /// - parameter identifier: A `String` holding reference to a valid thread identifier.
        public static func conversation(matching identifier: String) -> Paginated<Conversation.Unit, String?, Error> {
            .init { secret, session, pages in
                Pager(pages) {
                    base.threads
                        .path(appending: identifier)
                        .header(appending: secret.header)
                        .query(appending: ["visual_message_return_type": "unseen",
                                           "direction": $0.flatMap { _ in "older" },
                                           "cursor": $0,
                                           "limit": "20"])
                        .publish(with: session)
                        .map(\.data)
                        .wrap()
                        .map(Conversation.Unit.init)
                        .iterateFirst(stoppingAt: $0)
                }
                .eraseToAnyPublisher()
            }
        }

        /// Get user presence.
        public static var presence: Disposable<Wrapper, Error> {
            .init { secret, session in
                Deferred {
                    base.path(appending: "get_presence/")
                        .header(appending: secret.header)
                        .publish(with: session)
                        .map(\.data)
                        .wrap()
                }
                .eraseToAnyPublisher()
            }
        }
    }
}
