//
//  PaginatedType.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 26/08/20.
//

import Foundation

import ComposableRequest

/// A `struct` holding reference to pagination parameters.
public struct Pagination: Hashable {
    /// Next cursor.
    public var next: String?
    /// Whether more pages are available or not.
    public var canLoadMore: Bool { next != nil }
}

/// A `protocol` describing a response holding a paginated value.
public protocol PaginatedType: Wrapped, Bookmarkable {
    /// The pagination parameters.
    var bookmark: Pagination { get }
}

public extension PaginatedType {
    /// The pagination parameters.
    var bookmark: Pagination { .init(next: self["nextMaxId"].string()) }
}
