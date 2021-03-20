//
//  Conversation.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 20/03/21.
//

import Foundation

import Swiftagram

extension Conversation: Reflected {
    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["identifier": \Self.identifier,
                                                                    "title": \Self.title,
                                                                    "updatedAt": \Self.updatedAt,
                                                                    "openedAt": \Self.openedAt,
                                                                    "hasMutedMessages": \Self.hasMutedMessages,
                                                                    "hasMutedVideocalls": \Self.hasMutedVideocalls,
                                                                    "users": \Self.users,
                                                                    "messages": \Self.messages]
}

extension Conversation.Unit: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "Conversation." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["thread": \Self.conversation,
                                                                    "error": \Self.error]
}

extension Conversation.Collection: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "Conversation." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["threads": \Self.conversations,
                                                                    "viewer": \Self.viewer,
                                                                    "error": \Self.error]
}
