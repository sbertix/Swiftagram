//
//  Tag.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 20/04/21.
//

import Foundation

/// A `struct` defining a tag instance.
public struct Tag: Wrapped {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The identifier.
    public var identifier: String! {
        self["id"].string(converting: true)
    }

    /// The name.
    public var name: String! {
        self["name"].string(converting: true)
    }

    /// The amount of posts.
    public var count: Int! {
        self["mediaCount"].int()
    }

    /// Whether you're following it or not.
    public var isFollowed: Bool? {
        self["following"].bool()
    }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }
}
