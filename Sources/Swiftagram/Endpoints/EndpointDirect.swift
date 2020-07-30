//
//  EndpointDirect.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A `struct` holding reference to `direct_v2` `Endpoint`s. Requires authentication.
    struct Direct {
        /// The base endpoint.
        private static let base = Endpoint.version1.direct_v2.appendingDefaultHeader()

        /// All threads.
        /// - parameter page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func threads(startingAt page: String? = nil) -> PaginatedResponse {
            return base.inbox.paginating(key: "cursor", keyPath: \.oldestCursor, value: page).locking(Secret.self)
        }

        /// Top ranked recipients.
        public static let rankedRecipients: DisposableResponse = base.ranked_recipients.prepare().locking(Secret.self)

        /// A thread matching `identifier`.
        /// - parameters:
        ///     - identifier: A `String` holding reference to a valid thread identifier.
        ///     - page: An optional `String` holding reference to a valid cursor. Defaults to `nil`.
        public static func thread(matching identifier: String, startingAt page: String? = nil) -> PaginatedResponse {
            return base.threads
                .appending(path: identifier)
                .paginating(key: "cursor", keyPath: \.thread.oldestCursor, value: page)
                .locking(Secret.self)
        }
    }
}
