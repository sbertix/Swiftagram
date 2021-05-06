//
//  Paginatable.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 20/03/21.
//

import Foundation

public extension Paginatable where Self: Wrappable, Offset == String? {
    /// The pagination parameters.
    var offset: Offset { wrapped.nextMaxId.string() }
}
