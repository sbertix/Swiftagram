//
//  Secret.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest

/// A `struct` holding reference to an Instagram-specific `HeaderKey`.
public struct Secret: HeaderKey {
    /// All cookies.
    public private(set) var cookies: [CodableHTTPCookie]

    /// The associated `Client`. Defaults to `.default`.
    public var client: Client = .default

    // MARK: Computed properties

    /// All header fields.
    public var header: [String: String] {
        return HTTPCookie.requestHeaderFields(with: cookies.filter { $0.name != "urlgen" })
            .merging(
                ["X-IG-Device-ID": client.device.identifier.uuidString.lowercased(),
                 "X-IG-Android-ID": client.device.instagramIdentifier,
                 "X-MID": cookies.first(where: { $0.name == "mid"})?.value,
                 "User-Agent": client.description].compactMapValues { $0 },
                uniquingKeysWith: { _, rhs in rhs }
        )
    }

    /// A `String` representing the logged in user identifier.
    public var id: String {
        return cookies.first(where: { $0.name == "ds_user_id" })!.value
    }

    /// An `HTTPCookie` holding reference to the cross site request forgery token.
    public var crossSiteRequestForgery: HTTPCookie! {
        return cookies.first(where: { $0.name == "csrftoken" })
    }

    /// An `HTTPCookie` holding reference to the session identifier.
    public var session: HTTPCookie! {
        return cookies.first(where: { $0.name == "sessionid" })
    }

    // MARK: Accessories

    /// Return whether you have access to at least the required cookies.
    /// - parameter cookies: A `Collection` of `HTTPCookie`s.
    public static func hasValidCookies<Cookies: Collection>(_ cookies: Cookies) -> Bool where Cookies.Element: HTTPCookie {
        let required = ["ds_user_id", "sessionid", "csrftoken"]
        return cookies.count >= 3 && cookies.filter { required.contains($0.name) }.count >= 3
    }

    // MARK: Lifecycle

    /// Init.
    /// - parameters:
    ///     - cookies: A `Collection` of `HTTPCookie`s.
    ///     - client: A valid `Client`. Defaults to `.default`.
    public init?<Cookies: Collection>(cookies: Cookies, client: Client = .default) where Cookies.Element: HTTPCookie {
        guard Secret.hasValidCookies(cookies) else { return nil }
        self.cookies = cookies.compactMap(CodableHTTPCookie.init)
        self.client = client
    }
}
