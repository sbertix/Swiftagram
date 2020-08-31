//
//  PaginatedType.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/08/20.
//

import Foundation

import ComposableRequest

/// A `struct` holding reference to pagination parameters.
public struct Pagination {
    /// The current cursor.
    public var current: String?
    /// Next cursor.
    public var next: String?
    /// Whether more pages are available or not.
    public var canLoadMore: Bool { next != nil }
}

/// A `protocol` describing a response holding a paginated value.
public protocol PaginatedType: Wrapped {
    /// The pagination parameters.
    var pagination: Pagination { get }
}

public extension PaginatedType {
    /// The pagination parameters.
    var pagination: Pagination {
        .init(current: self["cursor"].string(),
              next: self["nextMaxId"].string())
    }
}
