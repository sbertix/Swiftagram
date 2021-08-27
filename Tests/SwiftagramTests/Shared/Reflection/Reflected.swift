//
//  Reflected.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/08/20.
//

import Foundation

import Requests

/// A `protocol` returning all underlying properties.
public protocol Reflected: Wrapped, CustomDebugStringConvertible {
    /// An optional prefix.
    static var debugDescriptionPrefix: String { get }

    /// A list of all properties.
    /// - note: This does not use `Mirror` reflection, to allow for computed properties and fine tuning.
    static var properties: [String: PartialKeyPath<Self>] { get }
}

public extension Reflected {
    /// A custom debug description.
    var debugDescription: String {
        let name = String(describing: Self.self)
        let properties = Self.properties
            .map { $0 + ": " + String(reflecting: self[keyPath: $1]) }
            .sorted { $0.count < $1.count }
            .joined(separator: ", ")
        return Self.debugDescriptionPrefix + name + "(" + properties + ")"
    }
}
