//
//  Media.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/08/2020.
//

import CoreGraphics
import Foundation

import ComposableRequest

/// A `struct` representing a `Media`.
public struct Media: ReflectedType {
    /// A `struct` representing some content `Version`.
    public struct Version: ReflectedType {
        /// The prefix.
        public static var debugDescriptionPrefix: String { "Media." }
        /// A list of to-be-reflected properties.
        public static let properties: [String: PartialKeyPath<Self>] = ["url": \Self.url,
                                                                        "size": \Self.size,
                                                                        "aspectRatio": \Self.aspectRatio,
                                                                        "resolution": \Self.resolution]

        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The `url`.
        public var url: URL? { self["url"].url() }
        /// The `size` value.
        public var size: CGSize? {
            guard let width = self["width"].double().flatMap(CGFloat.init),
                  let height = self["height"].double().flatMap(CGFloat.init) else { return nil }
            return .init(width: width, height: height)
        }

        /// The `aspectRatio` value, or `1`.
        public var aspectRatio: CGFloat { size.flatMap { $0.width/$0.height } ?? 1 }
        /// The `resolution` value, or `0`.
        public var resolution: CGFloat { size.flatMap { $0.width*$0.height } ?? 0 }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }

    /// A `struct` representing a `Picture`.
    public struct Picture: ReflectedType {
        /// The prefix.
        public static var debugDescriptionPrefix: String { "Media." }
        /// A list of to-be-reflected properties.
        public static let properties: [String: PartialKeyPath<Self>] = ["images": \Self.images]

        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// All picture versions.
        public var images: [Version]? {
            self["imageVersions2"]
                .candidates
                .array()?
                .compactMap { $0.optional().flatMap(Version.init) }
        }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }

    /// A `struct` representing a `Video`.
    public struct Video: ReflectedType {
        /// The prefix.
        public static var debugDescriptionPrefix: String { "Media." }
        /// A list of to-be-reflected properties.
        public static let properties: [String: PartialKeyPath<Self>] = ["duration": \Self.duration,
                                                                        "images": \Self.images,
                                                                        "clips": \Self.clips]

        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The video duration.
        public var duration: TimeInterval? {
            self["videoDuration"].double()
        }
        /// All picture versions.
        public var images: [Version]? {
            self["imageVersions2"]
                .candidates
                .array()?
                .map(Version.init)
        }
        /// All video versions.
        public var clips: [Version]? {
            self["videoVersions"]
                .array()?
                .map(Version.init)
        }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }

    /// An `enum` holding reference to the actual `Media` content.
    public enum Content: Wrapped, Codable {
        /// A picture.
        case picture(Picture)
        /// A video.
        case video(Video)
        /// An album.
        case album([Content])
        /// An error.
        case error(Wrapper)

        /// The user tags.
        public var tagged: [UserTag]? {
            self["usertags"]["in"].array()?.map(UserTag.init)
        }

        /// The underlying `Response`.
        public var wrapper: () -> Wrapper {
            switch self {
            case .picture(let picture): return picture.wrapper
            case .video(let video): return video.wrapper
            case .album(let content): return { content.map { $0.wrapper() }.wrapped }
            case .error(let error): return { error }
            }
        }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            let response = wrapper()
            switch response.mediaType.int() {
            case 1: self = .picture(.init(wrapper: response))
            case 2: self = .video(.init(wrapper: response))
            case 8: self = .album(response.carouselMedia.array()?.map(Content.init) ?? [])
            default: self = .error(response)
            }
        }
    }

    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["identifier": \Self.identifier,
                                                                    "primaryKey": \Self.primaryKey,
                                                                    "code": \Self.code,
                                                                    "wasLikedByYou": \Self.wasLikedByYou,
                                                                    "expiringAt": \Self.expiringAt,
                                                                    "takenAt": \Self.takenAt,
                                                                    "size": \Self.size,
                                                                    "aspectRatio": \Self.aspectRatio,
                                                                    "resolution": \Self.resolution,
                                                                    "caption": \Self.caption,
                                                                    "comments": \Self.comments,
                                                                    "likes": \Self.likes,
                                                                    "content": \Self.content,
                                                                    "user": \Self.user,
                                                                    "location": \Self.location]

    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The identifier.
    public var identifier: String! { (self["id"].optional() ?? self["mediaId"].optional())?.string(converting: true) }
    /// The primary key.
    public var primaryKey: Int! { self["pk"].int() }
    /// The code (for media URL).
    public var code: String? { self["code"].string() }

    /// The expiration date (if it exists).
    public var expiringAt: Date? { self["expiringAt"].date() }
    /// The time at which the media was captured.
    public var takenAt: Date? { self["takenAt"].date() }
    /// The original size.
    public var size: CGSize? {
        guard let width = self["originalWidth"].double(),
              let height = self["originalHeight"].double() else { return nil }
        return .init(width: width, height: height)
    }
    /// The `aspectRatio` value, or `1`.
    public var aspectRatio: CGFloat { size.flatMap { $0.width/$0.height } ?? 1 }
    /// The `resolution` value, or `0`.
    public var resolution: CGFloat { size.flatMap { $0.width*$0.height } ?? 0 }

    /// The caption.
    public var caption: Comment? { self["caption"].optional().flatMap(Comment.init) }
    /// The amount of comments.
    public var comments: Int? { self["commentCount"].int() }
    /// The amount of likes.
    public var likes: Int? { self["likeCount"].int() }
    /// Whether the current user has liked the media or not.
    public var wasLikedByYou: Bool? { self["hasLiked"].bool() }

    /// The actual content.
    public var content: Content { .init(wrapper: self.wrapper) }
    /// The media owner.
    public var user: User? {
        (self["user"].optional() ?? self["owner"].optional())
            .flatMap(User.init)
    }

    /// The location of the media.
    public var location: Location? { self["location"].optional().flatMap(Location.init) }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }
}

public extension Media {
    /// A `struct` representing a `Media` single response.
    struct Unit: ResponseType, ReflectedType {
        /// The prefix.
        public static var debugDescriptionPrefix: String { "Media." }
        /// A list of to-be-reflected properties.
        public static let properties: [String: PartialKeyPath<Self>] = ["media": \Self.media,
                                                                        "error": \Self.error]
        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The media.
        public var media: Media? {
            (self["media"].optional() ?? self["item"].optional()).flatMap(Media.init)
        }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }

    /// A `struct` representing a `Media` collection.
    struct Collection: ResponseType, ReflectedType, PaginatedType {
        /// The prefix.
        public static var debugDescriptionPrefix: String { "Media." }
        /// A list of to-be-reflected properties.
        public static let properties: [String: PartialKeyPath<Self>] = ["media": \Self.media,
                                                                        "pagination": \Self.pagination,
                                                                        "error": \Self.error]

        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The media.
        public var media: [Media]? { self["items"].array()?.map(Media.init) }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }
}
