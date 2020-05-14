//
//  EndpointUser.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A `struct` holding reference to `users` `Endpoint`s. Requires authentication.
    struct User {
        /// The base endpoint.
        private static let base = Endpoint.version1.users.defaultHeader()

        // MARK: Info
        /// A list of all profiles blocked by the user.
        public static let blocked: Disposable = base.blocked_list.prepare().locking(Secret.self)

        /// A user matching `identifier`'s info.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func summary(for identifier: String) -> Disposable {
            return base.append(path: identifier).info.prepare().locking(Secret.self)
        }

        /// All user matching `query`.
        /// - parameter query: A `String` holding reference to a valid user query.
        public static func all(matching query: String) -> Paginated {
            return base.search.append(query: "q", with: query).paginating().locking(Secret.self)
        }

        // MARK: Actions
        /// Report the user matching `identifier`.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        public static func report(_ identifier: String) -> Disposable {
            return base.append(path: identifier).flag_user
                .prepare()
                .locking(Secret.self) {
                    $0.append(header: $1.header)
                        .replace(body: [
                            "_csrftoken": $1.crossSiteRequestForgery.value,
                            "_uuid": Device.default.deviceGUID.uuidString,
                            "_uid": $1.identifier,
                            "user_id": identifier,
                            "source_name": "profile",
                            "is_spam": "true",
                            "reason_id": "1"
                        ])
                    }
        }
    }
}
