//
//  Deprecations.swift
//  Swiftagram
//
//  This file contains a list of all `unavailable` and `deprecated` declerations,
//  referencing (at least) the version in which they are going to be removed.
//
//  Created by Stefano Bertagno on 14/08/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// An `Endpoint` allowing for pagination.
    /// - note: Always reference this alias, to abstract away `ComposableRequest` implementation.
    /// - warning: This will be removed in version `4.1.0`.
    @available(*, deprecated, message: "use `Paginated<Wrapper>` instead; it will be removed in `4.1.0`.")
    typealias PaginatedResponse = Paginated<Wrapper>

    /// An `Endpoint` allowing for a single request.
    /// - note: Always reference this alias, to abstract away `ComposableRequest` implementation.
    /// - warning: This will be removed in version `4.1.0`.
    @available(*, deprecated, message: "use `Disposable<Wrapper>` instead; it will be removed in `4.1.0`.")
    typealias DisposableResponse = Disposable<Wrapper>

    /// An `Endpoint` allowing for pagination.
    /// - warning: This will be removed in version `4.1.0`.
    @available(*, deprecated, renamed: "PaginatedResponse", message: "it will be removed in `4.1.0`.")
    typealias ResponsePaginated = PaginatedResponse

    /// An `Endpoint` allowing for a single request.
    /// - warning: This will be removed in version `4.1.0`.
    @available(*, deprecated, renamed: "DisposableResponse", message: "it will be removed in `4.1.0`.")
    typealias ResponseDisposable = DisposableResponse
}

public extension Endpoint {
    struct Archive {
        /// Archived stories.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        /// - warning: This will be removed in version `4.1.0`.
        @available(*, deprecated, message: "use `Endpoint.Media.Stories.archived(startingAt:)` instead; it will be removed in `4.1.0`.")
        public static func stories(startingAt page: String? = nil) -> Paginated<TrayItemCollection> {
            Endpoint.Media.Stories.archived(startingAt: page)
        }
    }
}

public extension Endpoint.Direct {
    /// Top ranked recipients.
    /// - warning: This will be removed in version `4.1.0`.
    @available(*, deprecated, renamed: "recipients()", message: "it will be removed in `4.1.0`.")
    static var rankedRecipients: Endpoint.Disposable<ThreadRecipientCollection> {
        recipients()
    }
}

public extension Endpoint {
    /// A `struct` holding reference to `feed` and `usertags` `Endpoint`s. Requires authentication.
    struct Feed {
        /// Stories tray.
        /// - warning: This will be removed in version `4.1.0`.
        @available(
            *,
            deprecated,
            message: "use `Endpoint.Media.Stories.followed` instead; this will be removed in `4.1.0`"
        )
        public static var followedStories: Disposable<TrayItemCollection> {
            Endpoint.Media.Stories.followed
        }

        /// Liked media.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        /// - warning: This will be removed in version `4.1.0`.
        @available(
            *,
            deprecated,
            message: "use `Endpoint.Media.Posts.liked(startingAt:)` instead; this will be removed in `4.1.0`"
        )
        public static func liked(startingAt page: String? = nil) -> Paginated<MediaCollection> {
            Endpoint.Media.Posts.liked(startingAt: page)
        }

        /// All saved media.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        /// - warning: This will be removed in version `4.1.0`.
        @available(
            *,
            deprecated,
            message: "use `Endpoint.Media.Posts.saved(startingAt:)` instead; this will be removed in `4.1.0`"
        )
        public static func saved(startingAt page: String? = nil) -> Paginated<MediaCollection> {
            Endpoint.Media.Posts.saved(startingAt: page)
        }

        /// Timeline.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        /// - warning: This will be removed in version `4.1.0`.
        @available(
            *,
            deprecated,
            message: "use `Endpoint.Media.Posts.timeline(startingAt:)` instead; this will be removed in `4.1.0`"
        )
        public static func timeline(startingAt page: String? = nil) -> Paginated<Wrapper> {
            Endpoint.Media.Posts.timeline(startingAt: page)
        }

        /// All posts for user matching `identifier`.
        /// - parameters:
        ///     - identifier: A `String` holding reference to a valid user identifier.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        /// - warning: This will be removed in version `4.1.0`.
        @available(
            *,
            deprecated,
            message: "use `Endpoint.Media.Posts.by(_:,startingAt:)` instead; this will be removed in `4.1.0`"
        )
        public static func posts(by identifier: String, startingAt page: String? = nil) -> Paginated<MediaCollection> {
            Endpoint.Media.Posts.by(identifier, startingAt: page)
        }

        /// All available stories for user matching `identifier`.
        /// - parameters
        ///     - identifier: A `String` holding reference to a valid user identifier.
        /// - warning: This will be removed in version `4.1.0`.
        @available(
            *,
            deprecated,
            message: "use `Endpoint.Media.Stories.by(_:)` instead; this will be removed in `4.1.0`"
        )
        public static func stories(by identifier: String) -> Disposable<TrayItemUnit> {
            Endpoint.Media.Stories.by(identifier)
        }

        /// All posts a user matching `identifier` is tagged in.
        /// - parameters
        ///     - identifier: A `String` holding reference to a valid user identifier.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        /// - warning: This will be removed in version `4.1.0`.
        @available(
            *,
            deprecated,
            message: "use `Endpoint.Media.Posts.including(_:,startingAt:)` instead; this will be removed in `4.1.0`"
        )
        public static func posts(including identifier: String, startingAt page: String? = nil) -> Paginated<MediaCollection> {
            Endpoint.Media.Posts.including(identifier, startingAt: page)
        }

        /// All media matching `tag`.
        /// - parameters:
        ///     - tag: A `String` holding reference to a valid _#tag_.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        /// - warning: This will be removed in version `4.1.0`.
        @available(
            *,
            deprecated,
            message: "use `Endpoint.Media.Posts.tagged(with:,startingAt:)` instead; this will be removed in `4.1.0`"
        )
        public static func tagged(with tag: String, startingAt page: String? = nil) -> Paginated<MediaCollection> {
            Endpoint.Media.Posts.tagged(with: tag, startingAt: page)
        }
    }
}

public extension Endpoint.Highlights {
    /// Return the highlights tray for a specific user.
    /// - parameter identifier: A `String` holding reference to a valid user identifier.
    /// - warning: This will be removed in version `4.1.0`.
    @available(*, deprecated, renamed: "tray", message: "it will be removed in `4.1.0`.")
    static func highlights(for identifier: String) -> Endpoint.Disposable<TrayItemCollection> {
        tray(for: identifier)
    }
}

public extension Endpoint.Media {
    /// A list of all users liking the media matching `identifier`.
    /// - parameters:
    ///     - identifier: A `String` holding reference to a valid post media identifier.
    ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
    /// - warning: This will be removed in version `4.1.0`.
    @available(*, deprecated, message: "use `Endpoint.Media.Posts.likers(for:startingAt:)`; it will be removed in `4.1.0`.")
    static func likers(for identifier: String, startingAt page: String? = nil) -> Endpoint.Paginated<UserCollection> {
        return Posts.likers(for: identifier, startingAt: page)
    }

    /// A list of all comments the media matching `identifier`.
    /// - parameters:
    ///     - identifier: A `String` holding reference to a valid post media identifier.
    ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
    /// - warning: This will be removed in version `4.1.0`.
    @available(*, deprecated, message: "use `Endpoint.Media.Posts.comments(for:startingAt:)`; it will be removed in `4.1.0`.")
    static func comments(for identifier: String, startingAt page: String? = nil) -> Endpoint.Paginated<CommentCollection> {
        return Posts.comments(for: identifier, startingAt: page)
    }
}

public extension Endpoint.News {
    /// Latest news.
    /// - warning: This will be removed in version `4.1.0`.
    @available(*, deprecated, renamed: "recent", message: "it will be removed in `4.1.0`." )
    static var inbox: Endpoint.Disposable<Wrapper> { recent }
}

public extension Secret {
    /// A `String` representing the logged in user identifier.
    /// - warning: This will be removed in version `4.1.0`.
    @available(*, deprecated, renamed: "id", message: "it will be removed in `4.1.0`.")
    var identifier: String { id }
}

/// A `struct` holding reference to all transient `Secret`s.
/// - note: Use when only dealing with one-shot `Secret`s.
/// - warning: This alias will be removed in version `4.1.0`.
@available(*, deprecated, message: "import `ComposableRequest` and use `TransientStorage<Secret>` instead; this alias will be removed in `4.1.0`.")
public typealias TransientStorage = ComposableRequest.TransientStorage<Secret>

/// A `struct` holding reference to all `Secret`s stored in the `UserDefaults`.
/// - warning: `UserDefaults` are not safe for storing `Secret`s. **DO NOT USE THIS IN PRODUCTION**. This alias will be removed in version `4.1.0`.
/// - note:
///     `KeychainStorage` is the encoded and ready-to-use alternative to `UserDefaultsStorage`.
@available(*, deprecated, message: "import `ComposableRequest` and use `UserDefaultsStorage<Secret>` instead; this alias will be removed in `4.1.0`.")
public typealias UserDefaultsStorage = ComposableRequest.UserDefaultsStorage<Secret>
