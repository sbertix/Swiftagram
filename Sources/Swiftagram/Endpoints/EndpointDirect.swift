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
        private static let base = Endpoint.version1.direct_v2.defaultHeader().locking(authenticator: \.header)

        /// All threads.
        public static let threads = base.inbox.paginating(key: "cursor", initial: nil) { try? $0.get().oldestCursor.string() }
        /// Top ranked recipients.
        public static let rankedRecipients = base.ranked_recipients

        /// A thread matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid thread identifier.
        public static func thread(matching identifier: String) -> Paginated<Lock<Request>, Response> {
            return base.threads.append(identifier).paginating(key: "cursor", initial: nil) { try? $0.get().thread.oldestCursor.string() }
        }
    }
}
