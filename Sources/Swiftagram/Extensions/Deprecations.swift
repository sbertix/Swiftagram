//
//  Deprecations.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 17/08/2020.
//

import Foundation

public extension Endpoint.Direct {
    /// All threads.
    /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
    @available(*, deprecated, renamed: "inbox(startingAt:)", message: "(to be removed in `4.3.0`)")
    static func threads(startingAt page: String? = nil) -> Endpoint.Paginated<Conversation.Collection> {
        return inbox(startingAt: page)
    }

    /// All pending threads.
    /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
    @available(*, deprecated, renamed: "pendingInbox(startingAt:)", message: "(to be removed in `4.3.0`)")
    static func pendingThreads(startingAt page: String? = nil) -> Endpoint.Paginated<Conversation.Collection> {
        return pendingInbox(startingAt: page)
    }

    /// A thread matching `identifier`.
    /// - parameters:
    ///     - identifier: A `String` holding reference to a valid thread identifier.
    ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
    @available(*, deprecated, renamed: "conversation(matching:startingAt:)", message: "(to be removed in `4.3.0`)")
    static func thread(matching identifier: String, startingAt page: String? = nil) -> Endpoint.Paginated<Conversation.Unit> {
        return conversation(matching: identifier, startingAt: page)
    }
}
