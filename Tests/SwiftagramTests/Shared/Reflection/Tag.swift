//
//  Tag.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 20/04/21.
//

import Foundation

import Swiftagram

extension Tag: Reflected {
    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["id": \Self.identifier,
                                                                    "name": \Self.name,
                                                                    "mediaCount": \Self.count,
                                                                    "following": \Self.isFollowed]
}
