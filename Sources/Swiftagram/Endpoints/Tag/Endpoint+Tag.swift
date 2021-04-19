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
    static func tag(_ name: String) -> Endpoint.Single<Swiftagram.Tag, Error> {
        tag(name).summary
    }
}

extension Request {
    /// A tag-related request.
    ///
    /// - parameter tag: A valid `Tag`.
    /// - returns: A valid `Request`.
    static func tag(_ tag: Endpoint.Group.Tag) -> Request {
        Request.version1
            .tags
            .path(appending: tag.name)
            .appendingDefaultHeader()
    }
}

public extension Endpoint.Group.Tag {
    /// A summary for the current tag.
    ///
    /// - note: Prefer `Endpoint.tag(_:)` instead.
    var summary: Endpoint.Single<Swiftagram.Tag, Error> {
        .init { secret, session in
            Deferred {
                Request.tag(self)
                    .path(appending: "info/")
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Tag.init)
            }
            .eraseToAnyPublisher()
        }
    }

    /// A list of some recent stories for the current tag.
    var stories: Endpoint.Single<TrayItem.Unit, Error> {
        .init { secret, session in
            Deferred {
                Request.tag(self)
                    .path(appending: "story/")
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(TrayItem.Unit.init)
            }
            .eraseToAnyPublisher()
        }
    }
}
