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
        public static func summary(for identifier: String) -> Disposable {
            return base.appending(path: identifier).info.prepare().locking(Secret.self)
        }

        /// A list of all users liking the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func likers(for identifier: String) -> Paginated {
            return base.appending(path: identifier).likers.paginating().locking(Secret.self)
        }

        /// A list of all comments the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func comments(for identifier: String) -> Paginated {
            return base.appending(path: identifier).comments.paginating().locking(Secret.self)
        }

        /// The permalinkg for the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func permalink(for identifier: String) -> Disposable {
            return base.appending(path: identifier).permalink.prepare().locking(Secret.self)
        }

        // MARK: Actions
        /// Like the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func like(_ identifier: String) -> Disposable {
            return base.appending(path: identifier).like
                .prepare()
                .locking(Secret.self) {
                    $0.appending(header: $1.header)
                        .replacing(body: [
                            "_csrftoken": $1.crossSiteRequestForgery?.value,
                            "_uuid": Device.default.deviceGUID.uuidString,
                            "_uid": $1.identifier,
                            "media_id": identifier
                        ])
                }
        }

        /// Unlike the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func unlike(_ identifier: String) -> Disposable {
            return base.appending(path: identifier).unlike
                .prepare()
                .locking(Secret.self) {
                    $0.appending(header: $1.header)
                        .replacing(body: [
                            "_csrftoken": $1.crossSiteRequestForgery?.value,
                            "_uuid": Device.default.deviceGUID.uuidString,
                            "_uid": $1.identifier,
                            "media_id": identifier
                        ])
                }
        }

        /// Report a comment matching `identifier` in media matching `mediaIdentifier`.
        /// - parameters:
        ///     - identifier: A `String` holding reference to a valid comment identifier.
        ///     - mediaIdentifier: A `String` holding reference to a valid media identifier.
        public static func reportComment(_ identifier: String, in mediaIdentifier: String) -> Disposable {
            return base.appending(path: mediaIdentifier).comment.appending(path: identifier).flag
                .prepare()
                .locking(Secret.self) {
                    $0.appending(header: $1.header)
                        .replacing(body: [
                            "_csrftoken": $1.crossSiteRequestForgery?.value,
                            "_uuid": Device.default.deviceGUID.uuidString,
                            "_uid": $1.identifier,
                            "media_id": mediaIdentifier,
                            "comment_id": identifier,
                            "reason": "1"
                        ])
                }
        }
    }
}
