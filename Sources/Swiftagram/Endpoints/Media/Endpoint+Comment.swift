//
//  Endpoint+Comment.swift
//  ComposableRequest
//
//  Created by Stefano Bertagno on 01/04/21.
//

import Foundation

public extension Endpoint.Group.Media {
    /// A `class` defining comment endpoints.
    final class Comment {
        /// The media.
        public let media: Endpoint.Group.Media
        /// The comment identifier.
        public let identifier: String

        /// Init.
        ///
        /// - parameters:
        ///     - media: A valid `Endpoint.Group.Media`.
        ///     - identifier: A valid `String`.
        init(media: Endpoint.Group.Media,
             identifier: String) {
            self.media = media
            self.identifier = identifier
        }
    }

    /// A wrapper for comments endpoints.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Endpoint.Comment`.
    func comment(_ identifier: String) -> Comment {
        .init(media: self, identifier: identifier)
    }
}

public extension Endpoint.Group.Media.Comment {
    /// Like the underlying comment.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func like() -> Endpoint.Single<Status, Error> {
        Endpoint.Group.Media(identifier: self.identifier).edit("comment_like/")
    }

    /// Unlike the underlying comment.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unlike() -> Endpoint.Single<Status, Error> {
        Endpoint.Group.Media(identifier: self.identifier).edit("comment_unlike/")
    }
}
