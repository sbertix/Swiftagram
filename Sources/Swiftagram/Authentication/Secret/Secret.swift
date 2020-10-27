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
    /// An `enum` holding reference to `Secret`s coding keys, used to maintain backwords compatibility.
    private enum Keys: CodingKey {
        case cookies
        case client
        case device
    }

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
    ///
    /// - parameters:
    ///     - cookies: A `Collection` of `HTTPCookie`s.
    ///     - client: A valid `Client`. Defaults to `.default`.
    public init?<Cookies: Collection>(cookies: Cookies, client: Client = .default) where Cookies.Element: HTTPCookie {
        guard Secret.hasValidCookies(cookies) else { return nil }
        self.cookies = cookies.compactMap(CodableHTTPCookie.init)
        self.client = client
    }

    /// Init.
    ///
    /// - parameter decoder: A valid `Decoder`.
    /// - throws: Some `Error` related to the decoding process.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let cookies = try container.decode([CodableHTTPCookie].self, forKey: .cookies)
        // If `client` is non-`nil`, we do not need to upgrade the device.
        if let client = try container.decodeIfPresent(Client.self, forKey: .client) {
            self.cookies = cookies
            self.client = client
        } else if let device = try container.decodeIfPresent(LegacyDevice.self, forKey: .device),
                  let width = device.resolution.first,
                  let height = device.resolution.last {
            // Try to convert a previously stored `Device` into a new `Client`.
            self.cookies = cookies
            self.client = .init(application: .android(device.api, code: device.code),
                                device: .init(identifier: device.deviceGUID,
                                              phoneIdentifier: device.phoneGUID,
                                              adIdentifier: device.googleAdId,
                                              hardware: .init(model: device.model,
                                                              brand: device.brand,
                                                              boot: device.modelBoot,
                                                              cpu: device.cpu,
                                                              manufacturer: nil),
                                              software: .init(version: device.release+"/"+device.version,
                                                              language: "en_US"),
                                              resolution: .init(width: Int(width),
                                                                height: Int(height),
                                                                scale: 2,
                                                                dpi: device.dpi)))
        } else {
            // Otherwise we just raise an error.
            throw ResponseError.generic("Invalid cached `Secret`.")
        }
    }
}
