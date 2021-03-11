//
//  Comment.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/08/2020.
//

import Foundation

import ComposableRequest

/// A `struct` representing a `Comment`.
public struct Comment: ReflectedType {
    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["text": \Self.text,
                                                                    "likes": \Self.likes,
                                                                    "user": \Self.user,
                                                                    "identifier": \Self.identifier]

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
    struct Collection: ResponseType, PaginatedType, ReflectedType {
        /// The associated offset type.
        public typealias Offset = String?

        /// The prefix.
        public static var debugDescriptionPrefix: String { "Comment." }
        /// A list of to-be-reflected properties.
        public static let properties: [String: PartialKeyPath<Self>] = ["comments": \Self.comments,
                                                                        "error": \Self.error]

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
