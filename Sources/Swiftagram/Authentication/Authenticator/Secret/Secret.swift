//
//  Secret.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

/// A `struct` defining an `Authenticator` response.
public struct Secret: Codable {
    /// A `HTTPCookie` representing the logged in user identifier.
    public let identifier: HTTPCookie
    /// A `HTTPCookie` representing the `csrftoken` cookie.
    /// - note: Access is set to `private` to discourage developers to access sensitive information.
    private let crossSiteRequestForgery: HTTPCookie
    /// A `HTTPCookie` representinng the `sessionid` cookie.
    /// - note: Access is set to `private` to discourage developers to access sensitive information.
    private let session: HTTPCookie
    /// A `String` representing the logged in user identifier.
    public var id: String { return identifier.value }

    /// A `[String: String]` composed of all properties above.
    internal var headerFields: [String: String] {
        return HTTPCookie.requestHeaderFields(with: [identifier,
                                                     crossSiteRequestForgery,
                                                     session])
    }

    // MARK: Lifecycle.
    /// Init.
    /// - parameters:
    ///     - identifier: The `ds_user_id` cookie value.
    ///     - crossSiteRequestForgery: The `csrftoken` cookie value.
    ///     - session: The `sessionid` cookie value.
    public init(identifier: HTTPCookie,
                crossSiteRequestForgery: HTTPCookie,
                session: HTTPCookie) {
        self.identifier = identifier
        self.crossSiteRequestForgery = crossSiteRequestForgery
        self.session = session
    }

    /// Init from `Storage`.
    /// - parameters:
    ///     - identifier: The `ds_user_id` cookie value.
    ///     - storage: A concrete-typed value conforming to the `Storage` protocol.
    public static func stored<S: Storage>(with identifier: String, in storage: S) -> Secret? {
        return storage.find(matching: identifier)
    }

    // MARK: Locker
    /// Store in `storage`.
    /// - parameter storage: A concrete-typed value conforming to the `Storage` protocol.
    @discardableResult
    public func store<S: Storage>(in storage: S) -> Secret {
        storage.store(self)
        return self
    }

    /// Store in `storage`.
    /// - parameter storage: A value conforming to the `Storage` protocol.
    @discardableResult
    public func store(in storage: Storage) -> Secret {
        storage.store(self)
        return self
    }

    // MARK: Codable
    /// Encoding.
    /// - parameter encoder: An `Encoder`.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(identifier.data, forKey: .identifier)
        try container.encode(crossSiteRequestForgery.data, forKey: .crossSiteRequestForgery)
        try container.encode(session.data, forKey: .session)
    }

    /// Decoding.
    /// - parameter encoder: A `Decoder`.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        guard let identifier = try HTTPCookie(data: container.decode(Data.self, forKey: .identifier)),
            let crossSiteRequestForgery = try HTTPCookie(data: container.decode(Data.self, forKey: .crossSiteRequestForgery)),
            let session = try HTTPCookie(data: container.decode(Data.self, forKey: .session)) else { throw Error.invalidCookie }
        self.identifier = identifier
        self.crossSiteRequestForgery = crossSiteRequestForgery
        self.session = session
    }
}
