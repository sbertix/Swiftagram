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
public struct Location: ResponseMappable, CustomDebugStringConvertible {
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
    public var response: () throws -> Response

    /// The latitude.
    public var coordinates: Coordinates! {
        guard let latitude = self["lat"].double().flatMap(CGFloat.init),
              let longitude = self["lng"].double().flatMap(CGFloat.init) else { return nil }
        return .init(latitude: latitude, longitude: longitude)

    }
    /// The name.
    public var name: String? { self["name"].string() }
    /// The short name. Only populated for `summary`.
    public var shortName: String? { self["shortName"].string() }
    /// The address.
    public var address: String? { self["address"].string() }
    /// The city. Only populated for `summary`.
    public var city: String? { self["city"].string() }
    /// The external id (`value`), paired with its source (`key`).
    public var identifier: [String: Int]? {
        if let source = self["externalIdSource"].string(),
            let identifier = self["externalId"].int() {
            return [source: identifier]
        } else if let source = self["externalSource"].string() {
            return [source: self[source.camelCased+"Id"].int()].compactMapValues { $0 }
        } else {
            return nil
        }
    }

    /// Init.
    /// - parameter response: A valid `Response`.
    public init(response: @autoclosure @escaping () throws -> Response) {
        self.response = response
    }

    /// The debug description.
    public var debugDescription: String {
        ["Location(",
         ["coordinates": coordinates as Any,
          "name": name as Any,
          "shortName": shortName as Any,
          "address": address as Any,
          "city": city as Any,
          "identifier": identifier as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}

/// A `struct` representing a single `Location` response.
public struct LocationUnit: ResponseMappable, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var response: () throws -> Response

    /// The location.
    public var location: Location! { Location(response: self["location"]) }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter response: A valid `Response`.
    public init(response: @autoclosure @escaping () throws -> Response) {
        self.response = response
    }

    /// The debug description.
    public var debugDescription: String {
        ["LocationUnit(",
         ["location": location as Any,
          "status": status as Any]
            .mapValues { String(describing: $0 )}
            .map { "\($0): \($1)" }
            .joined(separator: ", "),
         ")"].joined()
    }
}

/// A `struct` representing a `Location` collection.
public struct LocationCollection: ResponseMappable, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var response: () throws -> Response

    /// The venues.
    public var venues: [Location]! { self["venues"].array()?.map { Location(response: $0) }}
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter response: A valid `Response`.
    public init(response: @autoclosure @escaping () throws -> Response) {
        self.response = response
    }

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
