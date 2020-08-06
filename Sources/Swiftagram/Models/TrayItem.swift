//
//  TrayItem.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 03/08/20.
//

import Foundation

import ComposableRequest

/// A `struct` representing a `TrayItem`.
public struct TrayItem: ResponseMappable, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var response: () throws -> Response

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
    public var cover: Response { self["coverMedia"] }
    /// The actual content.
    public var items: [Response]? { self["items"].array() }

    /// The expiration date of the tray item.
    public var expiringAt: Date? {
        return self["expiringAt"].date()
    }
    /// The date the tray was last seen on.
    public var lastSeenOn: Date? {
        return self["seen"].date()
    }

    /// The user.
    public var user: User? { self["user"].dictionary().flatMap { User(response: Response($0)) }}

    /// Whether the tray has content the logged in user can see being a close friend.
    public var containsCloseFriendsExclusives: Bool? { self["hasBestiesMedia"].bool() }

    /// Init.
    /// - parameter response: A valid `Response`.
    public init(response: @autoclosure @escaping () throws -> Response) {
        self.response = response
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
public struct TrayItemUnit: ResponseMappable, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var response: () throws -> Response

    /// The tray item.
    public var item: TrayItem! { (try? response()).flatMap { TrayItem(response: $0) }}
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter response: A valid `Response`.
    public init(response: @autoclosure @escaping () throws -> Response) {
        self.response = response
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
public struct TrayItemCollection: ResponseMappable, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var response: () throws -> Response

    /// The items.
    public var items: [TrayItem]! {
        (self["tray"].array() ?? self["items"].array())?.map { TrayItem(response: $0) }
    }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter response: A valid `Response`.
    public init(response: @autoclosure @escaping () throws -> Response) {
        self.response = response
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
