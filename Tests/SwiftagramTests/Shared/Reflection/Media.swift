//
//  Media.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 20/03/21.
//

import Foundation

import Swiftagram

extension Media.Version: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "Media." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["url": \Self.url,
                                                                    "size": \Self.size,
                                                                    "aspectRatio": \Self.aspectRatio,
                                                                    "resolution": \Self.resolution]
}

extension Media.Picture: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "Media." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["images": \Self.images]
}

extension Media.Video: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "Media." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["duration": \Self.duration,
                                                                    "images": \Self.images,
                                                                    "clips": \Self.clips]
}

extension Media: Reflected {
    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["identifier": \Self.identifier,
                                                                    "primaryKey": \Self.primaryKey,
                                                                    "code": \Self.code,
                                                                    "wasLikedByYou": \Self.wasLikedByYou,
                                                                    "expiringAt": \Self.expiringAt,
                                                                    "takenAt": \Self.takenAt,
                                                                    "size": \Self.size,
                                                                    "aspectRatio": \Self.aspectRatio,
                                                                    "resolution": \Self.resolution,
                                                                    "caption": \Self.caption,
                                                                    "comments": \Self.comments,
                                                                    "likes": \Self.likes,
                                                                    "content": \Self.content,
                                                                    "user": \Self.user,
                                                                    "location": \Self.location]
}

extension Media.Unit: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "Media." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["media": \Self.media,
                                                                    "error": \Self.error]
}

extension Media.Collection: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "Media." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["media": \Self.media,
                                                                    "error": \Self.error]
}
