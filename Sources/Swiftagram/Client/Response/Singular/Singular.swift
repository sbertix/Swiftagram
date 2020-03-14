//
//  Singular.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

/// A `protocol` defining a single expected `Response`, opposed to `Paginatable`.
public protocol Singular: Expecting { }

/// Defaults extensions for `Expecting`.
public extension Singular {
    /// Wrap a new `Expected` value.
    /// - parameter response: A concrete `DataMappable` type.
    func expecting<Response: DataMappable>(_ response: Response.Type) -> Expected<Self, Response> {
        return .init(expecting: self)
    }
}
