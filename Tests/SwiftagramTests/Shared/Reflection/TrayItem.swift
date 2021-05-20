//
//  TrayItem.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 20/03/21.
//

import Foundation

import Swiftagram

extension TrayItem: Reflected {
    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = [
        "identifier": \Self.identifier,
        "position": \Self.position,
        "seenPosition": \Self.seenPosition,
        "availableCount": \Self.availableCount,
        "fetchedCount": \Self.fetchedCount,
        "title": \Self.title,
        "cover": \Self.cover,
        "items": \Self.items,
        "expiringAt": \Self.expiringAt,
        "publishedAt": \Self.publishedAt,
        "seenAt": \Self.seenAt,
        "user": \Self.user,
        "isMuted": \Self.isMuted,
        "containsVideos": \Self.containsVideos,
        "containsCloseFriendsExclusives": \Self.containsCloseFriendsExclusives
    ]
}

extension TrayItem.Unit: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "TrayItem." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["item": \Self.item,
                                                                    "error": \Self.error]
}

extension TrayItem.Collection: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "TrayItem." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["items": \Self.items,
                                                                    "error": \Self.error]
}

extension TrayItem.Dictionary: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "TrayItem." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["items": \Self.items,
                                                                    "error": \Self.error]
}
