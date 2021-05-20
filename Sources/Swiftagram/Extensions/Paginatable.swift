//
//  Paginatable.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 20/03/21.
//

import Foundation

/// A `protocol` defining a `Paginatable` instance with an optional `String` offset.
public protocol StringPaginatable: Paginatable where Offset == String? { }

public extension Paginatable where Self: Wrappable, Offset == String? {
    /// The pagination parameters.
    var offset: Offset { wrapped.nextMaxId.string(converting: true) }
}
