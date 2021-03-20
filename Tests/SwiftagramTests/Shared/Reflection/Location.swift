//
//  Location.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 20/03/21.
//

import Foundation

import Swiftagram

extension Location: Reflected {
    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["coordinates": \Self.coordinates,
                                                                    "name": \Self.name,
                                                                    "shortName": \Self.shortName,
                                                                    "address": \Self.address,
                                                                    "city": \Self.city,
                                                                    "identifier": \Self.identifier]
}

extension Location.Unit: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "Location." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["location": \Self.location,
                                                                    "error": \Self.error]
}

extension Location.Collection: Reflected {
    /// The prefix.
    public static var debugDescriptionPrefix: String { "Location." }
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["venues": \Self.venues,
                                                                    "error": \Self.error]
}
