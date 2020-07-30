//
//  Location.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 30/07/20.
//

import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#else
public typealias CGFloat = Double
#endif

import ComposableRequest

/// A `class` representing a `Location`
public struct Location: ResponseMappable, Codable, CustomDebugStringConvertible {
    /// A `struct` holding reference to longitude and latitude.
    public struct Coordinates: Equatable {
        /// The longitude.
        public var longitude: CGFloat
        /// The latitude.
        public var latitude: CGFloat

        /// Init.
        /// - parameters:
        ///     - latitude: A `CGFloat` repreenting the latitude.
        ///     - longitude: A `CGFloat` repreenting the longitude.
        public init(latitude: CGFloat, longitude: CGFloat) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    /// The underlying `Response`.
    public var response: Response

    /// The latitude.
    public var coordinates: Coordinates! {
        guard let latitude = self["lat"].double().flatMap(CGFloat.init),
              let longitude = self["lng"].double().flatMap(CGFloat.init) else { return nil }
        return .init(latitude: latitude, longitude: longitude)

    }
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
         ["coordinates": coordinates as Any,
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
