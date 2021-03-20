//
//  User.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 20/03/21.
//

import Foundation

import Swiftagram

extension User: Reflected {
    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["identifier": \Self.identifier,
                                                                    "username": \Self.username,
                                                                    "name": \Self.name,
                                                                    "biography": \Self.biography,
                                                                    "thumbnail": \Self.thumbnail,
                                                                    "avatar": \Self.avatar,
                                                                    "access": \Self.access,
                                                                    "counter": \Self.counter,
                                                                    "friendship": \Self.friendship]
}

extension User.Unit: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "Comment." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["user": \Self.user,
                                                                    "error": \Self.error]
}

extension User.Collection: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "User." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["users": \Self.users,
                                                                    "error": \Self.error]
}
