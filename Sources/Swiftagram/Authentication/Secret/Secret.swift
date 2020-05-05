//
//  Secret.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import ComposableRequest
import Foundation

public struct Secret: Key {
    /// All cookies.
    public private(set) var cookies: [CodableHTTPCookie]

    /// User info.
    public var userInfo: [String: String]

    /// A `String` representing the logged in user identifier.
    public var identifier: String! {
        return cookies.first(where: { $0.name == "ds_user_id" })?.value
    }

    /// All header fields.
    public var header: [String: String] {
        let required = ["ds_user_id", "sessionid", "csrftoken"]
        return HTTPCookie.requestHeaderFields(with: cookies.filter { required.contains($0.name) })
    }

    /// An `HTTPCookie` holding reference to the cross site request forgery token.
    internal var crossSiteRequestForgery: HTTPCookie! {
        return cookies.first(where: { $0.name == "csrftoken" })
    }

    /// An `HTTPCookie` holding reference to the session identifier.
    internal var session: HTTPCookie! {
        return cookies.first(where: { $0.name == "sessionid" })
    }

    // MARK: Accessories
    /// Return whether you have access to at least the required cookies.
    /// - parameter cookies: A `Collection` of `HTTPCookie`s.
    public static func hasValidCookies<Cookies: Collection>(_ cookies: Cookies) -> Bool where Cookies.Element: HTTPCookie {
        let required = ["ds_user_id", "sessionid", "csrftoken"]
        return cookies.count >= 3 && cookies.filter { required.contains($0.name) }.count >= 3
    }

    // MARK: Lifecycle.
    /// Init.
    /// - parameters:
    ///     - cookies: A `Collection` of `HTTPCookie`s.
    ///     - userInfo: A `Dictionary` of `String`s. Defaults to empty.
    public init?<Cookies: Collection>(cookies: Cookies, userInfo: [String: String] = [:]) where Cookies.Element: HTTPCookie {
        guard Secret.hasValidCookies(cookies) else { return nil }
        self.cookies = cookies.compactMap(CodableHTTPCookie.init)
        self.userInfo = userInfo
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
    /// - parameter storage: A value conforming to the `Storage` protocol.
    @discardableResult
    public func store(in storage: Storage) -> Secret {
        storage.store(self)
        return self
    }
}
