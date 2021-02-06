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
        public static var inbox: Paginated<Conversation.Collection, RankedPageReference<String, String>?> {
            .init { secret, session, pages in
                // Persist the rank token.
                let rank = pages.offset?.rank ?? String(Int.random(in: 1_000..<10_000))
                // Prepare the actual pager.
                return Pager(pages) { _, next, _ in
                    base.inbox
                        .header(appending: secret.header)
                        .query(appending: ["visual_message_return_type": "unseen",
                                           "direction": next.flatMap { _ in "older" },
                                           "cursor": next,
                                           "thread_message_limit": "10",
                                           "persistent_badging": "true",
                                           "limit": "20",
                                           "seq_id": rank])
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Conversation.Collection.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// All pending threads.
        public static var pendingInbox: Paginated<Conversation.Collection, String?> {
            .init { secret, session, pages in
                Pager(pages) { _, next, _ in
                    base.path(appending: "pending_inbox")
                        .header(appending: secret.header)
                        .query(appending: ["visual_message_return_type": "unseen",
                                           "direction": next.flatMap { _ in "older" },
                                           "cursor": next,
                                           "thread_message_limit": "10",
                                           "persistent_badging": "true",
                                           "limit": "20"])
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Conversation.Collection.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// Top ranked recipients matching `query`.
        ///
        /// - parameter query: An optional `String`.
        public static func recipients(matching query: String? = nil) -> Disposable<Recipient.Collection> {
            .init { secret, session in
                Deferred {
                    base.path(appending: "ranked_recipients/")
                        .header(appending: secret.header)
                        .header(appending: ["mode": "raven",
                                            "query": query,
                                            "show_threads": "true"])
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Recipient.Collection.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// A thread matching `identifier`.
        /// 
        /// - parameter identifier: A `String` holding reference to a valid thread identifier.
        public static func conversation(matching identifier: String) -> Paginated<Conversation.Unit, String?> {
            .init { secret, session, pages in
                Pager(pages) { _, next, _ in
                    base.threads
                        .path(appending: identifier)
                        .header(appending: secret.header)
                        .query(appending: ["visual_message_return_type": "unseen",
                                           "direction": next.flatMap { _ in "older" },
                                           "cursor": next,
                                           "limit": "20"])
                        .session(session)
                        .map(\.data)
                        .wrap()
                        .map(Conversation.Unit.init)
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }

        /// Get user presence.
        public static var presence: Disposable<Wrapper> {
            .init { secret, session in
                Deferred {
                    base.path(appending: "get_presence/")
                        .header(appending: secret.header)
                        .session(session)
                        .map(\.data)
                        .wrap()
                }
                .eraseToAnyObservable()
                .observe(on: session.scheduler)
            }
        }
    }
}
