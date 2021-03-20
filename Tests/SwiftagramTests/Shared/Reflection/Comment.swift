//
//  Comment.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 20/03/21.
//

import Foundation

import Swiftagram

extension Comment: Reflected {
    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["text": \Self.text,
                                                                    "likes": \Self.likes,
                                                                    "user": \Self.user,
                                                                    "identifier": \Self.identifier]
}

extension Comment.Collection: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "Comment." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["comments": \Self.comments,
                                                                    "error": \Self.error]
}
