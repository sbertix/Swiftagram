//
//  Endpoint+Media.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 27/03/21.
//

import Core
import Foundation

public extension Endpoint.Group {
    /// A `class` defining media endpoints.
    final class Media {
        /// The media identifier.
        public let identifier: String

        /// Init.
        ///
        /// - parameter identifier: A valid `String`.
        init(identifier: String) {
            self.identifier = identifier
        }
    }
}

public extension Endpoint {
    /// A wrapper for media endpoints.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Endpoint.Media`.
    static func media(_ identifier: String) -> Endpoint.Group.Media {
        .init(identifier: identifier)
    }

    /// A wrapper for media endpoints.
    ///
    /// - parameter media: A valid `Media`.
    /// - returns: A valid `Endpoint.Media`.
    static func media(_ media: Swiftagram.Media) -> Endpoint.Group.Media {
        self.media(media.identifier)
    }

    /// A summary for the current media.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    static func media(_ identifier: String) -> Endpoint.Single<Swiftagram.Media.Unit> {
        media(identifier).summary
    }
}

extension Request {
    /// The media request.
    static let media = Request.version1.media.appendingDefaultHeader()

    /// A specific media request.
    ///
    /// - parameter media: A valid `Endpoint.Media` identifier.
    /// - returns: A valid `Request`.
    static func media(_ media: String) -> Request {
        Request.media.path(appending: media)
    }
}

public extension Endpoint.Group.Media {
    /// An `enum` listing media-related error.
    enum Error: Swift.Error {
        /// Artifact.
        case artifact(Wrapper)
        /// Invalid shortchode.
        case invalidShortcode(String)
        /// Invalid URL.
        case invalidURL(URL)
        /// Unsupported type.
        case unsupportedType(Int?)
        /// Video too long.
        case videoTooLong(seconds: TimeInterval)
    }
}

public extension Endpoint.Group.Media {
    /// A summary for the current media.
    ///
    /// - note: Prefer `Endpoint.media(_:)` instead.
    var summary: Endpoint.Single<Swiftagram.Media.Unit> {
        .init { secret, requester in
            Request.media(self.identifier)
                .info
                .header(appending: secret.header)
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Swiftagram.Media.Unit.init)
                .requested(by: requester)
        }
    }

    /// A list of comments for the current media.
    var comments: Endpoint.Paginated<String?, Swiftagram.Comment.Collection> {
        .init { secret, pages, requester in
            Receivables.Pager(pages) {
                Request.media(self.identifier)
                    .comments
                    .header(appending: secret.header)
                    .query(appending: $0, forKey: "max_id")
                    .prepare(with: requester)
                    .map(\.data)
                    .decode()
                    .map(Swiftagram.Comment.Collection.init)
            }
            .requested(by: requester)
        }
    }

    /// A list of likers for the current media.
    var likers: Endpoint.Paginated<String?, Swiftagram.User.Collection> {
        .init { secret, pages, requester in
            Receivables.Pager(pages) {
                Request.media(self.identifier)
                    .likers
                    .header(appending: secret.header)
                    .query(appending: $0, forKey: "max_id")
                    .prepare(with: requester)
                    .map(\.data)
                    .decode()
                    .map(Swiftagram.User.Collection.init)
            }
            .requested(by: requester)
        }
    }

    /// Fetch the permalink for the current media.
    var link: Endpoint.Single<Swiftagram.Media.Link> {
        .init { secret, requester in
            Request.media(self.identifier)
                .permalink
                .header(appending: secret.header)
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Swiftagram.Media.Link.init)
                .requested(by: requester)
        }
    }

    /// Fetch all viewers for the current story.
    var viewers: Endpoint.Paginated<String?, Swiftagram.User.Collection> {
        .init { secret, pages, requester in
            Receivables.Pager(pages) {
                Request.media(self.identifier)
                    .path(appending: "list_reel_media_viewer")
                    .header(appending: secret.header)
                    .query(appending: $0, forKey: "max_id")
                    .prepare(with: requester)
                    .map(\.data)
                    .decode()
                    .map(Swiftagram.User.Collection.init)
            }
            .requested(by: requester)
        }
    }

    /// Save the current media.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func save() -> Endpoint.Single<Status> {
        edit("save/")
    }

    /// Unsave the current media.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unsave() -> Endpoint.Single<Status> {
        edit("unsave/")
    }
}

extension Endpoint.Group.Media {
    /// Edit the current media.
    ///
    /// - parameter endpoint: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    func edit(_ endpoint: String) -> Endpoint.Single<Status> {
        .init { secret, requester in
            Request.media(self.identifier)
                .path(appending: endpoint)
                .method(.post)
                .header(appending: secret.header)
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Status.init)
                .requested(by: requester)
        }
    }
}
