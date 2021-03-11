//
//  PaginatedType.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/08/20.
//

import Foundation

/// A `protocol` describing a response holding a paginated value.
public protocol PaginatedType: Wrapped, Paginatable {
    /// The pagination parameters.
    var offset: Offset { get }
}

public extension PaginatedType where Offset == String? {
    /// The pagination parameters.
    var offset: Offset { self["nextMaxId"].string() }
}
