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
public struct Media: Wrapped, Codable, CustomDebugStringConvertible {
    /// A `struct` representing some content `Version`.
    public struct Version: Wrapped, Codable, CustomDebugStringConvertible {
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

        /// The debug description.
        public var debugDescription: String {
            ["Media.Version(",
             ["url": url as Any,
              "size": size as Any,
              "aspectRatio": aspectRatio as Any,
              "resolution": resolution as Any]
                .mapValues { String(describing: $0 )}
                .map { "\($0): \($1)" }
                .joined(separator: ", "),
             ")"].joined()
        }
    }

    /// A `struct` representing a `Picture`.
    public struct Picture: Wrapped, Codable, CustomDebugStringConvertible {
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

        /// The debug description.
        public var debugDescription: String {
            ["Media.Picture(",
             ["images": images as Any]
                .mapValues { String(describing: $0 )}
                .map { "\($0): \($1)" }
                .joined(separator: ", "),
             ")"].joined()
        }
    }

    /// A `struct` representing a `Video`.
    public struct Video: Wrapped, Codable, CustomDebugStringConvertible {
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

        /// The debug description.
        public var debugDescription: String {
            ["Media.Video(",
             ["images": images as Any,
              "videos": clips as Any,
              "duration": duration as Any]
                .mapValues { String(describing: $0 )}
                .map { "\($0): \($1)" }
                .joined(separator: ", "),
             ")"].joined()
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

    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The identifier.
    public var identifier: String! { self["mediaId"].string(converting: true) }
    /// The primary key.
    public var primaryKey: Int! { self["pk"].int() }

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

    /// The debug description.
    public var debugDescription: String {
        ["Media(",
         ["identifier": identifier as Any,
          "expiringAt": expiringAt as Any,
          "takenAt": takenAt as Any,
          "size": size as Any,
          "aspectRatio": aspectRatio as Any,
          "resolution": resolution as Any,
          "caption": caption as Any,
          "comments": comments as Any,
          "likes": likes as Any,
          "content": content as Any,
          "user": user as Any,
          "location": location as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}

/// A `struct` representing a `Media` single response.
public struct MediaUnit: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The media.
    public var media: Media? {
        (self["media"].optional() ?? self["item"].optional()).flatMap(Media.init)
    }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }

    /// The debug description.
    public var debugDescription: String {
        ["MediaUnit(",
         ["media": media as Any,
          "status": status as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}

/// A `struct` representing a `Media` collection.
public struct MediaCollection: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The media.
    public var media: [Media]? { self["items"].array()?.map(Media.init) }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
    }

    /// The debug description.
    public var debugDescription: String {
        ["MediaCollection(",
         ["media": media as Any,
          "status": status as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}
