//
//  Conversation.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 10/08/20.
//

import Foundation

/// A `struct` representing a `Conversation`.
public struct Conversation: Wrapped {
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
}

public extension Conversation {
    /// A `struct` representing a `Conversation` single response.
    struct Unit: Specialized, Paginatable {
        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The thread.
        public var conversation: Conversation? { self["thread"].optional().flatMap(Conversation.init) }

        /// The pagination parameters.
        public var offset: String? { self["thread"]["oldestCursor"].string(converting: true) }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }

    /// A `struct` representing a `Conversation` collection.
    struct Collection: Specialized, Paginatable {
        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The threads.
        public var conversations: [Conversation]? { self["inbox"].threads.array()?.map(Conversation.init) }
        /// The logged in user.
        public var viewer: User? { self["viewer"].optional().flatMap(User.init) }

        /// The pagination parameters.
        public var offset: String? { self["inbox"]["oldestCursor"].string(converting: true) }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }
}
