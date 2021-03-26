//
//  Direct.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 25/03/21.
//

import Foundation

public extension Endpoint {
    /// A module-like `enum` defining `direct_v2` endpoints.
    struct Direct: Parent { }

    /// A wrapper for direct endpoints.
    static let direct: Direct = .init()
}

extension Request {
    /// The `direct_v2` base request.
    static let direct = Endpoint.version1.direct_v2
    /// The threads base request.
    static let directThreads = Request.direct.threads
}

public extension Endpoint.Direct {
    /// Get the user presence.
    var activity: Endpoint.Disposable<Wrapper, Error> {
        disposable(at: Request.direct.path(appending: "get_presence/"))
    }

    /// Paginate all approved conversations in your inbox.
    var conversations: Endpoint.Paginated<Swiftagram.Conversation.Collection, String?, Error> {
        inbox(isPending: false)
    }

    /// Fetch all suggested recipients.
    var recipients: Endpoint.Disposable<Recipient.Collection, Error> {
        recipients(matching: nil)
    }

    /// Paginate the pending requests inbox.
    var requests: Endpoint.Paginated<Swiftagram.Conversation.Collection, String?, Error> {
        inbox(isPending: true)
    }

    /// Fetch all recipients, optinally matching a given query.
    ///
    /// - parameter query: A valid `String`.
    /// - returns: An `Endpoint.Disposable`.
    func recipients(matching query: String) -> Endpoint.Disposable<Recipient.Collection, Error> {
        recipients(matching: .some(query))
    }
}

fileprivate extension Endpoint.Direct {
    /// Fetch the inbox.
    ///
    /// - parameter isPending: A valid `Bool`.
    /// - returns: An `Endpoint.Paginated`.
    func inbox(isPending: Bool) -> Endpoint.Paginated<Swiftagram.Conversation.Collection, String?, Error> {
        paginated(at: isPending ? Request.direct.path(appending: "pending_inbox") : Request.direct.inbox) {
            $3.query(appending: ["visual_message_return_type": "unseen",
                                 "direction": $2.flatMap { _ in "older" },
                                 "cursor": $2,
                                 "thread_message_limit": "10",
                                 "persistent_badging": "true",
                                 "limit": "20"])
        }
    }

    /// Fetch all recipients, optinally matching a given query.
    ///
    /// - parameter query: An optional `String`. 
    /// - returns: An `Endpoint.Disposable`.
    func recipients(matching query: String?) -> Endpoint.Disposable<Recipient.Collection, Error> {
        disposable(at: Request.direct.path(appending: "ranked_recipients/")) {
            $2.header(appending: ["mode": "raven",
                                  "query": query,
                                  "show_threads": "true"])
        }
    }
}
