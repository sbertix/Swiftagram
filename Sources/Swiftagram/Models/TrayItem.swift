//
//  TrayItem.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 03/08/20.
//

import Foundation

import ComposableRequest

/// A `struct` representing a `TrayItem`.
public struct TrayItem: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The identifier.
    public var identifier: String! { self["id"].string() ?? self["id"].int().flatMap(String.init) }

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
            ?? self["timestamp"].int().flatMap(String.init)
            ?? self["timestamp"].string()
            ?? user?.username
    }
    /// The last media primary key.
    public var latestMediaPrimaryKey: Int? { self["latestReelMedia"].int() }
    /// The cover media.
    public var cover: Wrapper? { self["coverMedia"].optional() }
    /// The actual content.
    public var items: [Wrapper]? { self["items"].array() }

    /// The expiration date of the tray item.
    public var expiringAt: Date? {
        return self["expiringAt"].date()
    }
    /// The date the tray was last seen on.
    public var lastSeenOn: Date? {
        return self["seen"].date()
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

    /// The debug description.
    public var debugDescription: String {
        ["TrayItem(",
         ["identifier": identifier as Any,
          "position": position as Any,
          "seenPosition": seenPosition as Any,
          "title": title as Any,
          "latestMediaPrimaryKey": latestMediaPrimaryKey as Any,
          "cover": cover as Any,
          "user": user as Any,
          "containsCloseFriendsExclusives": containsCloseFriendsExclusives as Any,
          "expiringAt": expiringAt as Any,
          "lastSeenOn": lastSeenOn as Any,
          "items": items as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}

/// A `struct` representing a `TrayItem` single response.
public struct TrayItemUnit: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The tray item.
    public var item: TrayItem? { wrapper().optional().flatMap(TrayItem.init)  }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }

    /// The debug description.
    public var debugDescription: String {
        ["TrayItemUnit(",
         ["item": item as Any,
          "status": status as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}

/// A `struct` representing a `TrayItem` collection.
public struct TrayItemCollection: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The items.
    public var items: [TrayItem]? {
        (self["tray"].array() ?? self["items"].array())?.map(TrayItem.init)
    }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }

    /// The debug description.
    public var debugDescription: String {
        ["TrayItemCollection(",
         ["items": items as Any,
          "status": status as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}
