//
//  SavedCollection.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 19/04/21.
//

import Foundation

import Swiftagram

extension SavedCollection: Reflected {
    /// The prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["collectionId": \Self.identifier,
                                                                    "collectionName": \Self.name,
                                                                    "collectionMediaType": \Self.type,
                                                                    "collectionMediaCount": \Self.count,
                                                                    "coverMediaList": \Self.cover,
                                                                    "items": \Self.items]
}

extension SavedCollection.Unit: Reflected {
    /// The prefix.
    public static let debugDescriptionPrefix: String = "SavedCollection."
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["saveMediaResponse": \Self.collection]
}

extension SavedCollection.Collection: Reflected {
    /// The prefix.
    public static let debugDescriptionPrefix: String = "SavedCollection."
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["items": \Self.collections]
}
