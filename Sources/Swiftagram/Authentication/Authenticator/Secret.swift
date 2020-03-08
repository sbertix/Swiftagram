//
//  Secret.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

/// A `struct` defining an `Authenticator` response.
public struct Secret: Codable {
    /// A `String` representing the logged in user identifier.
    public let id: String
    /// A `HTTPCookie` representing the logged in user identifier.
    public let identifier: Data
    /// A `HTTPCookie` representing the `csrftoken` cookie.
    /// - note: Access is set to `private` to discourage developers to access sensitive information.
    private let crossSiteRequestForgery: Data
    /// A `HTTPCookie` representinng the `sessionid` cookie.
    /// - note: Access is set to `private` to discourage developers to access sensitive information.
    private let session: Data

    /// A `[String: String]` composed of all properties above.
    internal var headerFields: [String: String] {
        return HTTPCookie.requestHeaderFields(with: [identifier,
                                                     crossSiteRequestForgery,
                                                     session].compactMap { HTTPCookie(data: $0) })
    }

    // MARK: Lifecycle.
    /// Init.
    /// - parameter identifier: The `ds_user_id` cookie value.
    /// - parameter crossSiteRequestForgery: The `csrftoken` cookie value.
    /// - parameter session: The `sessionid` cookie value.
    public init(identifier: HTTPCookie,
                crossSiteRequestForgery: HTTPCookie,
                session: HTTPCookie) {
        self.id = identifier.value
        self.identifier = identifier.data
        self.crossSiteRequestForgery = crossSiteRequestForgery.data
        self.session = session.data
    }
    /// Init from `Storage`.
    /// - parameter identifier: The `ds_user_id` cookie value.
    /// - parameter storage: A concrete-typed value conforming to the `Storage` protocol.
    public static func stored<S: Storage>(with identifier: String, in storage: S) -> Secret? {
        return storage.find(matching: identifier)
    }

    // MARK: Locker
    @discardableResult
    /// Store in `storage`.
    /// - parameter storage: A concrete-typed value conforming to the `Storage` protocol.
    public func store<S: Storage>(in storage: S) -> Secret {
        storage.store(self)
        return self
    }

    @discardableResult
    /// Store in `storage`.
    /// - parameter storage: A value conforming to the `Storage` protocol.
    public func store(in storage: Storage) -> Secret {
        storage.store(self)
        return self
    }
}
