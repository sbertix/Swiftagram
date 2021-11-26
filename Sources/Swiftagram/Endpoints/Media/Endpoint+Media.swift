//
//  Endpoint+Media.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 27/03/21.
//

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
    static func media(_ identifier: String) -> Endpoint.Single<Swiftagram.Media.Collection, Swift.Error> {
        media(identifier).summary
    }

    /// A wrapper for media endpoints.
    ///
    /// - parameter url: A valid `URL`.
    /// - throws: Some `Media.Error`.
    /// - returns: A valid `Media`.
    static func media(at url: URL) throws -> Endpoint.Group.Media {
        // Prepare the `URL`.
        let components = url.pathComponents
        guard let postIndex = components.firstIndex(of: "p"), postIndex < components.count - 1 else {
            throw Group.Media.Error.invalidURL(url)
        }
        let shortcode = components[postIndex + 1]
        // Process the shortcode.
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
        let set = CharacterSet(charactersIn: alphabet)
        guard shortcode.rangeOfCharacter(from: set.inverted) == nil else {
            throw Group.Media.Error.invalidShortcode(shortcode)
        }
        // Prepare the identifier.
        var identifier: Int64 = 0
        shortcode.forEach {
            guard let value = alphabet.firstIndex(of: $0)?.utf16Offset(in: alphabet) else { return }
            identifier = identifier * 64 + Int64(value)
        }
        return .init(identifier: String(identifier))
    }

    /// A summary for the media at the given url.
    ///
    /// - parameter url: A valid `URL`.
    /// - returns: A valid `Endpoint.Single`.
    static func media(at url: URL) -> Endpoint.Single<Swiftagram.Media.Collection, Swift.Error> {
        .init { secret, session in
            Just(url)
                .tryMap(self.media)
                .flatMap { $0.summary.unlock(with: secret).session(session) }
                .eraseToAnyPublisher()
        }
    }
}

extension Request {
    /// The media request.
    static let media = Request.version1.media.appendingDefaultHeader()

    /// A specific media request.
    ///
    /// - parameter media: A valid `Endpoint.Media`.
    /// - returns: A valid `Request`.
    static func media(_ media: Endpoint.Group.Media) -> Request {
        Request.media.path(appending: media.identifier)
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
    var summary: Endpoint.Single<Swiftagram.Media.Collection, Swift.Error> {
        .init { secret, session in
            Deferred {
                Request.media(self)
                    .info
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Media.Collection.init)
            }
            .replaceFailingWithError()
        }
    }

    /// A list of comments for the current media.
    var comments: Endpoint.Paginated < Swiftagram.Comment.Collection,
                                     RankedOffset<String?, String?>,
                                     Swift.Error> {
        .init { secret, session, pages in
            // Persist the rank token.
            let rank = pages.rank ?? UUID().uuidString
            // Prepare the actual pager.
            return Pager(pages) {
                Request.media(self)
                    .comments
                    .header(appending: secret.header)
                    .header(appending: rank, forKey: "rank_token")
                    .query(appending: $0, forKey: "max_id")
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Comment.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .replaceFailingWithError()
        }
    }

    /// A list of likers for the current media.
    var likers: Endpoint.Paginated < Swiftagram.User.Collection,
                                   RankedOffset<String?, String?>,
                                   Swift.Error> {
        .init { secret, session, pages in
            // Persist the rank token.
            let rank = pages.rank ?? UUID().uuidString
            // Prepare the actual pager.
            return Pager(pages) {
                Request.media(self)
                    .likers
                    .header(appending: secret.header)
                    .header(appending: rank, forKey: "rank_token")
                    .query(appending: $0, forKey: "max_id")
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.User.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .replaceFailingWithError()
        }
    }

    /// Fetch the permalink for the current media.
    var link: Endpoint.Single<Swiftagram.Media.Link, Swift.Error> {
        .init { secret, session in
            Deferred {
                Request.media(self)
                    .permalink
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Media.Link.init)
            }
            .replaceFailingWithError()
        }
    }

    /// Fetch all viewers for the current story.
    var viewers: Endpoint.Paginated < Swiftagram.User.Collection,
                                    RankedOffset<String?, String?>,
                                    Swift.Error> {
        .init { secret, session, pages in
            // Persist the rank token.
            let rank = pages.rank ?? UUID().uuidString
            // Prepare the actual pager.
            return Pager(pages) {
                Request.media(self)
                    .path(appending: "list_reel_media_viewer")
                    .header(appending: secret.header)
                    .header(appending: rank, forKey: "rank_token")
                    .query(appending: $0, forKey: "max_id")
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.User.Collection.init)
                    .iterateFirst(stoppingAt: $0)
            }
            .replaceFailingWithError()
        }
    }

    /// Save the current media.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func save() -> Endpoint.Single<Status, Swift.Error> {
        edit("save/")
    }

    /// Unsave the current media.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unsave() -> Endpoint.Single<Status, Swift.Error> {
        edit("unsave/")
    }
}

extension Endpoint.Group.Media {
    /// Edit the current media.
    ///
    /// - parameter endpoint: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    func edit(_ endpoint: String) -> Endpoint.Single<Status, Swift.Error> {
        .init { secret, session in
            Deferred {
                Request.media(self)
                    .path(appending: endpoint)
                    .method(.post)
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Status.init)
            }
            .replaceFailingWithError()
        }
    }
}
