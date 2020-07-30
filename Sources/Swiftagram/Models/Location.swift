//
//  Location.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 30/07/20.
//

import Foundation

import ComposableRequest

/// A `class` representing a `Location`
public struct Location: ResponseMappable, Codable, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var response: Response

    /// The latitude.
    public var latitude: CGFloat! { self["lat"].double().flatMap(CGFloat.init) }
    /// The longitude.
    public var longitude: CGFloat! { self["lng"].double().flatMap(CGFloat.init) }
    /// The name.
    public var name: String? { self["name"].string() }
    /// The address.
    public var address: String? { self["address"].string() }
    /// The external id (`value`), paired with its source (`key`).
    public var identifier: [String: Int]? {
        guard let source = self["externalIdSource"].string(),
              let identifier = self["externalId"].int() else {
            return nil
        }
        return [source: identifier]
    }

    /// Init.
    /// - parameter response: A valid `Response`.
    public init(response: Response) { self.response = response }

    /// The debug description.
    public var debugDescription: String {
        ["Location(",
         ["latitude": latitude as Any,
          "longitude": longitude as Any,
          "name": name as Any,
          "address": address as Any,
          "identifier": identifier as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}

/// A `struct` representing a `Location` collection.
public struct LocationCollection: ResponseMappable, Codable, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var response: Response

    /// The venues.
    public var venues: [Location]! { self["venues"].array()?.map(Location.init) }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter response: A valid `Response`.
    public init(response: Response) { self.response = response }

    /// The debug description.
    public var debugDescription: String {
        ["LocationCollection(",
         ["venues": venues as Any,
          "status": status as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}
