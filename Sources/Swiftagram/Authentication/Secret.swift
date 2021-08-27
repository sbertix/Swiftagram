//
//  Secret.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import Storages

/// A `struct` defining the logged in user authentication parameters.
///
/// `cookies` and `client` are only ever valid as a pair: if you need to change the `Client`,
/// just authenticate again, passing the new one to the `Authenticator`.
///
/// - note: The information contained by any given instance of `Secret` is extremely sensitive. Please handle it with care.
public struct Secret: Codable, Storable {
    /// The associated `Client`. Defaults to `.default`.
    public let client: Client

    /// The authenticated user primary key.
    public let identifier: String
    /// The storable label.
    public var label: String { identifier }

    /// All authentication cookies.
    ///
    /// - note: This information is extremely sensitive. Please handle it with care.
    let cookies: [CodableHTTPCookie]

    /// All header fields.
    ///
    /// - note: This information is extremely sensitive. Please handle it with care.
    public var header: [String: String] {
        HTTPCookie.requestHeaderFields(with: cookies)
            .merging(["X-IG-Device-ID": client.device.identifier.uuidString.lowercased(),
                      "X-IG-Android-ID": client.device.instagramIdentifier,
                      "X-MID": cookies.first { $0.name == "mid" }?.value,
                      "User-Agent": client.description].compactMapValues { $0 }) { _, rhs in rhs }
    }

    // MARK: Lifecycle

    /// Init.
    ///
    /// - parameters:
    ///     - cookies: A `Collection` of `HTTPCookie`s.
    ///     - client: A valid `Client`. Defaults to `.default`.
    public init?<Cookies: Collection>(cookies: Cookies, client: Client = .default) where Cookies.Element: HTTPCookie {
        guard cookies.containsAuthenticationCookies,
              let identifier = cookies.first(where: { $0.name == "ds_user_id" })?.value else { return nil }
        self.cookies = cookies.compactMap(CodableHTTPCookie.init)
        self.client = client
        self.identifier = identifier
    }

    // MARK: Codable

    /// Init.
    ///
    /// - parameter decoder: A valid `Decoder`.
    /// - throws: Some `Error` related to the decoding process.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let cookies = try container.decode([CodableHTTPCookie].self, forKey: .cookies)
        // Check for identifier.
        guard let identifier = cookies.first(where: { $0.name == "ds_user_id" })?.value else {
            throw Authenticator.Error.generic("Identifier for `Secret` not found.")
        }
        self.identifier = identifier
        // If `client` is non-`nil`, we do not need to upgrade the device.
        if let client = try container.decodeIfPresent(Client.self, forKey: .client) {
            self.cookies = cookies
            self.client = client
        } else if let device = try container.decodeIfPresent(LegacyDevice.self, forKey: .device),
                  let width = device.resolution.first,
                  let height = device.resolution.last {
            // Try to convert a previously stored `Device` into a new `Client`.
            self.cookies = cookies
            self.client = .init(device: device, width: Int(width), height: Int(height))

            #if DEBUG
            print("———————")
            print("`LegacyDevice` will lose support starting with `5.1.0`.")
            print("All your users will be logged out automatically.")
            print("At that point, by logging back in, they'll be migrated")
            print("to the safer `Client`-based instance, added with `4.2.0`")
            print("in October, 2020.")
            print("———————")
            #endif
        } else {
            // Otherwise we just raise an error.
            throw Authenticator.Error.generic("Invalid cached `Secret`.")
        }
    }

    /// Encode into `Data`.
    ///
    /// - parameter encoder: A valid `Encoder`.
    /// - returns: Some `Data`.
    /// - throws: Some `Error` related to the encoding process.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(client, forKey: .client)
        try container.encode(cookies, forKey: .cookies)
    }

    /// Return a specific cookie value.
    ///
    /// - parameter key: A valid `HTTPCookie` `name`.
    /// - returns: A valid `String`, representing the matching `HTTPCookie` `value`.
    /// - note: This information is extremely sensitive. Please handle it with care.
    public subscript(_ key: String) -> String {
        guard let value = cookies.first(where: { $0.name == key })?.value else {
            fatalError("`key` not found in `Secret` cookies.")
        }
        return value
    }
}

fileprivate extension Secret {
    /// An `enum` holding reference to `Secret`s coding keys, used to maintain backwords compatibility.
    enum Keys: CodingKey {
        case cookies
        case client
        case device
    }
}
