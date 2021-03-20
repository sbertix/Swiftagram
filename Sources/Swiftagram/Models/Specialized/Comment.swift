//
//  Comment.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/08/2020.
//

import Foundation

/// A `struct` representing a `Comment`.
public struct Comment: Wrapped {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The comment primary key.
    public var identifier: String! { self["pk"].string(converting: true) }
    /// The `text` value.
    public var text: String! { self["text"].string() }
    /// The `commentLikeCount` value.
    public var likes: Int? { self["commentLikeCount"].int() }
    /// The `user` value.
    public var user: User? {
        (self["user"].optional() ?? self["owner"].optional())
            .flatMap(User.init)
    }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }
}

public extension Comment {
    /// A `struct` representing a `Comment` collection.
    struct Collection: Specialized, Paginatable {
        /// The associated offset type.
        public typealias Offset = String?

        /// The underlying `Wrapper`.
        public var wrapper: () -> Wrapper

        /// The comments.
        public var comments: [Comment]? {
            (self["comments"].optional() ?? self["previewComments"].optional())?
                .array()?
                .map(Comment.init)
        }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }
}
