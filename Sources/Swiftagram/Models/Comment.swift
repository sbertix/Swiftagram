//
//  Comment.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/08/2020.
//

import Foundation

import ComposableRequest

/// A `struct` representing a `Comment`.
public struct Comment: Wrapped, Codable, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

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

    /// The debug description.
    public var debugDescription: String {
        ["Comment(",
         ["text": text as Any,
          "likes": likes as Any,
          "user": user as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}

/// A `struct` representing a `Comment` collection.
public struct CommentCollection: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The comments.
    public var comments: [Comment]? { self["previewComments"].array()?.map(Comment.init) }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }

    /// The debug description.
    public var debugDescription: String {
        ["CommentCollection(",
         ["comments": comments as Any,
          "status": status as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}
