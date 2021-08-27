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
    static var direct: Group.Direct { .init() }
}

extension Request {
    /// The `direct_v2` base request.
    static let direct = Request.version1.direct_v2.appendingDefaultHeader()
    /// The threads base request.
    static let directThreads = Request.direct.threads.appendingDefaultHeader()
}

public extension Endpoint.Group.Direct {
    /// Get the user presence.
    var activity: Endpoint.Single<Wrapper> {
        .init { secret, requester in
            Request.direct
                .path(appending: "get_presence/")
                .header(appending: secret.header)
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .requested(by: requester)
        }
    }

    /// Paginate all approved conversations in your inbox.
    var conversations: Endpoint.Paginated<String?, Swiftagram.Conversation.Collection> {
        inbox(isPending: false)
    }

    /// Fetch all suggested recipients.
    var recipients: Endpoint.Single<Recipient.Collection> {
        recipients(matching: nil)
    }

    /// Paginate the pending requests inbox.
    var requests: Endpoint.Paginated<String?, Swiftagram.Conversation.Collection> {
        inbox(isPending: true)
    }

    /// Fetch all recipients, optinally matching a given query.
    ///
    /// - parameter query: A valid `String`.
    /// - returns: An `Endpoint.Single`.
    func recipients(matching query: String) -> Endpoint.Single<Recipient.Collection> {
        recipients(matching: .some(query))
    }
}

fileprivate extension Endpoint.Group.Direct {
    /// Fetch the inbox.
    ///
    /// - parameter isPending: A valid `Bool`.
    /// - returns: An `Endpoint.Paginated`.
    func inbox(isPending: Bool) -> Endpoint.Paginated<String?, Swiftagram.Conversation.Collection> {
        .init { secret, pages, requester in
            Receivables.Pager(pages) {
                Request.direct
                    .path(appending: isPending ? "pending_inbox" : "inbox")
                    .header(appending: secret.header)
                    .query(appending: ["visual_message_return_type": "unseen",
                                       "direction": $0.flatMap { _ in "older" },
                                       "cursor": $0,
                                       "thread_message_limit": "10",
                                       "persistent_badging": "true",
                                       "limit": "20"])
                    .prepare(with: requester)
                    .map(\.data)
                    .decode()
                    .map(Swiftagram.Conversation.Collection.init)
            }
            .requested(by: requester)
        }
    }

    /// Fetch all recipients, optinally matching a given query.
    ///
    /// - parameter query: An optional `String`. 
    /// - returns: An `Endpoint.Single`.
    func recipients(matching query: String?) -> Endpoint.Single<Recipient.Collection> {
        .init { secret, requester in
            Request.direct
                .path(appending: "ranked_recipients/")
                .header(appending: secret.header)
                .header(appending: ["mode": "raven",
                                    "query": query,
                                    "show_threads": "true"])
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Recipient.Collection.init)
                .requested(by: requester)
        }
    }
}
