//
//  EndpointFriendship.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import ComposableRequest
import Foundation

public extension Endpoint {
    /// A `struct` holding reference to `friendships` `Endpoint`s. Requires authentication.
    struct Friendship {
        /// The base endpoint.
        private static let base = Endpoint.version1.friendships.defaultHeader().locked()

        /// A list of users followed by the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        /// - note: This is equal to the user's **following**.
        public static func followed(by identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.append(identifier).following.paginating()
        }

        /// A list of users following the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        /// - note: This is equal to the user's **followers**.
        public static func following(_ identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.append(identifier).followers.paginating()
        }

        /// The current friendship status between the authenticated user and the one matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func friendship(with identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.show.append(identifier).paginating()
        }
    }
}
