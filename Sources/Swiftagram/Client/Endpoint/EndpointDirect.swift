//
//  EndpointDirect.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

public extension Endpoint {
    /// A `struct` holding reference to `direct_v2` `Endpoint`s. Requires authentication.
    struct Direct {
        /// The base endpoint.
        private static let base = Endpoint.version1.direct_v2.defaultHeader().locked()

        /// All threads.
        public static let threads = base.reel.inbox

        /// A thread matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid thread identifier.
        public static func thread(matching identifier: String) -> Locked<ComposableRequest> {
            return base.threads.append(identifier)
        }
    }
}
