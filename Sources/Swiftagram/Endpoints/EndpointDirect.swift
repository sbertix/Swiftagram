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
        private static let base = Endpoint.version1.direct_v2.defaultHeader()

        /// All threads.
        public static let threads: Paginated = base.inbox.paginating(key: "cursor", keyPath: \.oldestCursor).locking(Secret.self)
        /// Top ranked recipients.
        public static let rankedRecipients: Disposable = base.ranked_recipients.prepare().locking(Secret.self)

        /// A thread matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid thread identifier.
        public static func thread(matching identifier: String) -> Paginated {
            return base.threads.appending(path: identifier).paginating(key: "cursor", keyPath: \.thread.oldestCursor).locking(Secret.self)
        }
    }
}
