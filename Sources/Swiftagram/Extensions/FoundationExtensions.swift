//
//  FoundationExtensions.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 13/03/2020.
//

import Foundation

/// A global `func` to create a copy of a `struct` and return it after mapping it.
internal func copy<Item>(_ item: Item, handle: (inout Item) -> Void) -> Item {
    var copy = item
    handle(&copy)
    return copy
}
