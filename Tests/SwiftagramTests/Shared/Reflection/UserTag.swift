//
//  UserTag.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 20/03/21.
//

import Foundation

import Swiftagram

extension UserTag: Reflected {
    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["identifier": \Self.identifier,
                                                                    "x": \Self.x,
                                                                    "y": \Self.y]
}
