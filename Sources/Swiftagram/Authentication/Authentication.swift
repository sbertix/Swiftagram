//
//  Authentication.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

/// A `struct` defining everything related to the login flow.
public struct Authentication {
    /// A `struct` defining an `Authentication` response.
    public struct Response: Codable {
        /// A `String` representing the logged in user identifier.
        public let identifier: String
        /// A `String` representing the `csrftoken` cookie.
        /// - note: Access is set to `private` to discourage developers to access sensitive information.
        private let crossSiteRequestForgery: String
        /// A `String` representinng the `sessionid` cookie.
        /// - note: Access is set to `private` to discourage developers to access sensitive information.
        private let session: String

        /// A `[String: String]` composed of all properties above.
        internal var headerFields: [String: String] {
            return ["ds_user_id": identifier,
                    "sessionid": session,
                    "csrftoken": crossSiteRequestForgery]
        }

        // MARK: Lifecycle.
        /// Init.
        /// - parameter identifier: The `ds_user_id` cookie value.
        /// - parameter crossSiteRequestForgery: The `csrftoken` cookie value.
        /// - parameter session: The `sessionid` cookie value.
        public init(identifier: String,
                    crossSiteRequestForgery: String,
                    session: String) {
            self.identifier = identifier
            self.crossSiteRequestForgery = crossSiteRequestForgery
            self.session = session
        }
        /// Init from `Storage`.
        /// - parameter identifier: The `ds_user_id` cookie value.
        /// - parameter storage: A concrete-typed value conforming to the `Storage` protocol.
        public static func stored<S: Storage>(with identifier: String, in storage: S) -> Response? {
            return storage.find(matching: identifier)
        }

        // MARK: Locker
        /// Store in `storage`.
        /// - parameter storage: A concrete-typed value conforming to the `Storage` protocol.
        public func store<S: Storage>(in storage: S) {
            storage.store(self)
        }
    }
}
