//
//  EndpointMedia.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A `struct` holding reference to `media` `Endpoint`s. Requires authentication.
    struct Media {
        /// The base endpoint.
        private static let base = Endpoint.version1.media.defaultHeader()

        // MARK: Info
        /// A media matching `identifier`'s info.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func summary(for identifier: String) -> Lock<Request> {
            return base.locking(into: Lock.self).append(identifier).info
        }

        /// A list of all users liking the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func likers(for identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.locking(into: Lock.self).append(identifier).likers.paginating()
        }

        /// A list of all comments the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func comments(for identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.locking(into: Lock.self).append(identifier).comments.paginating()
        }

        /// The permalinkg for the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func permalink(for identifier: String) -> Lock<Request> {
            return base.locking(into: Lock.self).append(identifier).permalink
        }

        // MARK: Actions
        /// Like the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func like(_ identifier: String) -> CustomLock<Request> {
            return base.append(identifier).like
                .locking {
                    guard let secret = $1 as? Secret else {
                        fatalError("A `Swiftagram.Secret` is required to authenticate `.like`.")
                    }
                    return $0.header(secret.headerFields)
                        .body("_csrftoken", value: secret.crossSiteRequestForgery.value)
                        .body("_uuid", value: Device.default.deviceGUID.uuidString)
                        .body("_uid", value: secret.id)
                        .body("media_id", value: identifier)
                }
        }

        /// Unlike the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func unlike(_ identifier: String) -> CustomLock<Request> {
            return base.append(identifier).unlike
                .locking {
                    guard let secret = $1 as? Secret else {
                        fatalError("A `Swiftagram.Secret` is required to authenticate `.unlike`.")
                    }
                    return $0.header(secret.headerFields)
                        .body("_csrftoken", value: secret.crossSiteRequestForgery.value)
                        .body("_uuid", value: Device.default.deviceGUID.uuidString)
                        .body("_uid", value: secret.id)
                        .body("media_id", value: identifier)
                }
        }

        /// Report a comment matching `identifier` in media matching `mediaIdentifier`.
        /// - parameters:
        ///     - identifier: A `String` holding reference to a valid comment identifier.
        ///     - mediaIdentifier: A `String` holding reference to a valid media identifier.
        public static func reportComment(_ identifier: String, in mediaIdentifier: String) -> CustomLock<Request> {
            return base.append(mediaIdentifier).comment.append(identifier).flag
                .locking {
                    guard let secret = $1 as? Secret else {
                        fatalError("A `Swiftagram.Secret` is required to authenticate `.reportComment`.")
                    }
                    return $0.header(secret.headerFields)
                        .body("_csrftoken", value: secret.crossSiteRequestForgery.value)
                        .body("_uuid", value: Device.default.deviceGUID.uuidString)
                        .body("_uid", value: secret.id)
                        .body("media_id", value: mediaIdentifier)
                        .body("comment_id", value: identifier)
                        .body("reason", value: "1")
                }
        }
    }
}
