//
//  TrayItem.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 03/08/20.
//

import Foundation

/// A `struct` representing a `TrayItem`.
public struct TrayItem: Wrapped {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The identifier.
    public var identifier: String! { self["id"].string(converting: true) }

    /// The ranked position.
    public var position: Int? { self["rankedPosition"].int() }
    /// The seen ranked position.
    public var seenPosition: Int? { self["seenRankedPosition"].int() }
    /// The media count.
    public var availableCount: Int? { self["mediaCount"].int() }
    /// The count of media that have actually been fetched.
    public var fetchedCount: Int? { self["prefetchCount"].int() }

    /// The title, main timestamp of the tray item or author username.
    public var title: String? {
        self["title"].string()
            ?? self["timestamp"].string(converting: true)
            ?? user?.username
    }
    /// The last media primary key.
    public var latestMediaPrimaryKey: Int? { self["latestReelMedia"].int() }
    /// The cover media.
    public var cover: Media? { self["coverMedia"].optional().flatMap(Media.init) }
    /// The actual content.
    public var items: [Media]? { self["items"].array()?.map(Media.init) }

    /// The expiration date of the tray item.
    public var expiringAt: Date? {
        self["expiringAt"].date()
    }
    /// The date the tray was last seen on.
    public var lastSeenOn: Date? {
        self["seen"].date()
    }

    /// The user.
    public var user: User? { self["user"].optional().flatMap { User(wrapper: $0) }}

    /// Whether the tray has content the logged in user can see being a close friend.
    public var containsCloseFriendsExclusives: Bool? { self["hasBestiesMedia"].bool() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }
}

public extension TrayItem {
    /// A `struct` representing a `TrayItem` single response.
    struct Unit: ResponseType {
        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The tray item.
        public var item: TrayItem? {
            (wrapper()["story"].optional()
                ?? wrapper()["item"].optional()
                ?? wrapper().optional())
                .flatMap(TrayItem.init)
        }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }

    /// A `struct` representing a `TrayItem` collection.
    struct Collection: ResponseType, Paginatable {
        /// The associated offset type.
        public typealias Offset = String?

        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The items.
        public var items: [TrayItem]? {
            (self["tray"].array() ?? self["items"].array())?.map(TrayItem.init)
        }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }

    /// A `struct` representing a `TrayItem` dictionary.
    struct Dictionary: ResponseType {
        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The items.
        public var items: [String: TrayItem]? {
            self["reels"].dictionary()?.compactMapValues { $0.optional().flatMap(TrayItem.init) }
        }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }
}
