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
        private static let base = Endpoint.version1.media.defaultHeader().locked()

        /// A media matching `identifier`'s info.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func summary(for identifier: String) -> Locked<Request> {
            return base.append(identifier).info
        }

        /// A list of all users liking the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func likers(for identifier: String) -> Paginated<Locked<Request>, Response> {
            return base.append(identifier).likers.paginating()
        }

        /// A list of all comments the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func comments(for identifier: String) -> Paginated<Locked<Request>, Response> {
            return base.append(identifier).comments.paginating()
        }

        /// The permalinkg for the media matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid media identifier.
        public static func permalink(for identifier: String) -> Locked<Request> {
            return base.append(identifier).permalink
        }
    }
}
