//
//  Conversation.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 10/08/20.
//

import Foundation

import ComposableRequest

/// A `struct` representing a `Conversation`.
public struct Conversation: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The identifier.
    public var identifier: String! { self["threadId"].string(converting: true) }
    /// The title.
    public var title: String! { self["threadTitle"].string() }
    /// Last update.
    public var updatedAt: Date? { self["lastActivityAt"].date() }
    /// Last seen for `identifier`.
    public var openedAt: [String: Date]? {
        self["lastSeenAt"].dictionary()?.compactMapValues { $0.timestamp.date() }
    }
    /// Muted.
    public var hasMutedMessages: Bool? { self["muted"].bool() }
    /// Muted videocalls.
    public var hasMutedVideocalls: Bool? { self["vcMuted"].bool() }
    /// Users.
    public var users: [User]? { self["users"].array()?.map(User.init) }

    /// The actual messages.
    public var messages: [Wrapper]? { self["items"].array() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }

    /// The debug description.
    public var debugDescription: String {
        ["Conversation(",
         ["identifier": identifier as Any,
          "title": title as Any,
          "updatedAt": updatedAt as Any,
          "openedAt": openedAt as Any,
          "hasMutedMessages": hasMutedMessages as Any,
          "hasMutedVideocalls": hasMutedVideocalls as Any,
          "messages": messages as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}

/// A `struct` representing a `Conversation` single response.
public struct ConversationUnit: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The thread.
    public var thread: Conversation? { self["thread"].optional().flatMap(Conversation.init) }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }

    /// The debug description.
    public var debugDescription: String {
        ["ConversationUnit(",
         ["thread": thread as Any,
          "status": status as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}

/// A `struct` representing a `Conversation` collection.
public struct ConversationCollection: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The threads.
    public var threads: [Conversation]? { self["inbox"].threads.array()?.map(Conversation.init) }
    /// The logged in user.
    public var viewer: User? { self["viewer"].optional().flatMap(User.init) }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }

    /// The debug description.
    public var debugDescription: String {
        ["ConversationCollection(",
         ["threads": threads as Any,
          "viewer": viewer as Any,
          "status": status as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}
