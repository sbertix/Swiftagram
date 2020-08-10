//
//  Thread.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 10/08/20.
//

import Foundation

import ComposableRequest

/// A `struct` representing a `Thread`.
public struct Thread: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The identifier.
    public var identifier: String! { self["threadId"].string() }
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
        ["Thread(",
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

/// A `struct` representing a `Thread` single response.
public struct ThreadUnit: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The thread.
    public var thread: Thread? { self["thread"].optional().flatMap(Thread.init) }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }

    /// The debug description.
    public var debugDescription: String {
        ["ThreadUnit(",
         ["thread": thread as Any,
          "status": status as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}

/// A `struct` representing a `Thread` collection.
public struct ThreadCollection: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The threads.
    public var threads: [Thread]? { self["inbox"].threads.array()?.map(Thread.init) }
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
        ["ThreadCollection(",
         ["threads": threads as Any,
          "viewer": viewer as Any,
          "status": status as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}
