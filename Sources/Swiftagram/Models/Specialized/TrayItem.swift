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

    /// The cover media.
    public var cover: Media? { self["coverMedia"].optional().flatMap(Media.init) }

    /// The actual content.
    public var items: [Media]? { self["items"].array()?.map(Media.init) }

    /// The expiration date of the tray element, if it exists.
    public var expiringAt: Date? {
        self["expiringAt"].int() == 0 ? nil : self["expiringAt"].date()
    }

    /// The latest reel media date, if it exists.
    public var publishedAt: Date? {
        self["latestReelMedia"].int() == 0 ? nil : self["latestReelMedia"].date()
    }

    /// The date you last opened the tray element, if it exists.
    public var seenAt: Date? {
        self["seen"].int() == 0 ? nil : self["seen"].date()
    }

    /// The user.
    public var user: User? {
        self["user"].optional().flatMap { User(wrapper: $0) }
    }

    /// Whether it's muted or not.
    public var isMuted: Bool? {
        self["muted"].bool() ?? user?.friendship?.isMutingStories
    }

    /// Whether the tray has video content.
    public var containsVideos: Bool? {
        self["hasVideo"].bool()
    }

    /// Whether the tray has content the logged in user can see being a close friend.
    public var containsCloseFriendsExclusives: Bool? {
        self["hasBestiesMedia"].bool()
    }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }
}

public extension TrayItem {
    /// A `struct` representing a `TrayItem` single response.
    struct Unit: Specialized {
        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The tray item.
        public var item: TrayItem? {
            (wrapper()["story"].optional()
                ?? wrapper()["reel"].optional()
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
    struct Collection: Specialized, StringPaginatable {
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
    struct Dictionary: Specialized {
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
