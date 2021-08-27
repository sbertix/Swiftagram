//
//  Endpoint+Tag.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/04/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `class` defining tag endpoints.
    final class Tag {
        /// The tag name.
        public let name: String

        /// Init.
        ///
        /// - parameter name: A valid `String`.
        init(name: String) {
            self.name = name
        }
    }
}

public extension Endpoint {
    /// A wrapper for tag-specific endpoints.
    ///
    /// - parameter name: A valid `String`.
    /// - returns: A valid `Tag`.
    static func tag(_ name: String) -> Group.Tag {
        .init(name: name)
    }

    /// A summary for the current tag.
    ///
    /// - parameter name: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    static func tag(_ name: String) -> Endpoint.Single<Swiftagram.Tag> {
        tag(name).summary
    }
}

extension Request {
    /// A tag-related request.
    ///
    /// - parameter tag: A valid `Tag` name.
    /// - returns: A valid `Request`.
    static func tag(_ tag: String) -> Request {
        Request.version1
            .tags
            .path(appending: tag)
            .appendingDefaultHeader()
    }
}

public extension Endpoint.Group.Tag {
    /// A summary for the current tag.
    ///
    /// - note: Prefer `Endpoint.tag(_:)` instead.
    var summary: Endpoint.Single<Swiftagram.Tag> {
        .init { secret, requester in
            Request.tag(self.name)
                .path(appending: "info/")
                .appendingDefaultHeader()
                .header(appending: secret.header)
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Swiftagram.Tag.init)
                .requested(by: requester)
        }
    }

    /// A list of some recent stories for the current tag.
    var stories: Endpoint.Single<TrayItem.Unit> {
        .init { secret, requester in
            Request.tag(self.name)
                .path(appending: "story/")
                .appendingDefaultHeader()
                .header(appending: secret.header)
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(TrayItem.Unit.init)
                .requested(by: requester)
        }
    }
}
