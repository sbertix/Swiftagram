//
//  Direct.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 25/03/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `class` defining `direct_v2` endpoints.
    final class Direct { }
}

public extension Endpoint {
    /// A wrapper for direct endpoints.
    static let direct: Group.Direct = .init()
}

extension Request {
    /// The `direct_v2` base request.
    static let direct = Request.version1.direct_v2.appendingDefaultHeader()
    /// The threads base request.
    static let directThreads = Request.direct.threads.appendingDefaultHeader()
}

public extension Endpoint.Group.Direct {
    /// Get the user presence.
    var activity: Endpoint.Single<Wrapper, Error> {
        .init { secret, session in
            Deferred {
                Request.direct
                    .path(appending: "get_presence/")
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
            }
            .eraseToAnyPublisher()
        }
    }

    /// Paginate all approved conversations in your inbox.
    var conversations: Endpoint.Paginated<Swiftagram.Conversation.Collection, String?, Error> {
        inbox(isPending: false)
    }

    /// Fetch all suggested recipients.
    var recipients: Endpoint.Single<Recipient.Collection, Error> {
        recipients(matching: nil)
    }

    /// Paginate the pending requests inbox.
    var requests: Endpoint.Paginated<Swiftagram.Conversation.Collection, String?, Error> {
        inbox(isPending: true)
    }

    /// Fetch all recipients, optinally matching a given query.
    ///
    /// - parameter query: A valid `String`.
    /// - returns: An `Endpoint.Single`.
    func recipients(matching query: String) -> Endpoint.Single<Recipient.Collection, Error> {
        recipients(matching: .some(query))
    }
}

fileprivate extension Endpoint.Group.Direct {
    /// Fetch the inbox.
    ///
    /// - parameter isPending: A valid `Bool`.
    /// - returns: An `Endpoint.Paginated`.
    func inbox(isPending: Bool) -> Endpoint.Paginated<Swiftagram.Conversation.Collection, String?, Error> {
        .init { secret, session, pages in
            Pager(pages) {
                Request.direct
                    .path(appending: isPending ? "pending_inbox" : "inbox")
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
                    .map(Swiftagram.Conversation.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .eraseToAnyPublisher()
        }
    }

    /// Fetch all recipients, optinally matching a given query.
    ///
    /// - parameter query: An optional `String`. 
    /// - returns: An `Endpoint.Single`.
    func recipients(matching query: String?) -> Endpoint.Single<Recipient.Collection, Error> {
        .init { secret, session in
            Deferred {
                Request.direct
                    .path(appending: "ranked_recipients/")
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
}
