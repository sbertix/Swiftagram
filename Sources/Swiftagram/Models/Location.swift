//
//  Location.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 30/07/20.
//

import CoreGraphics
import Foundation

import ComposableRequest

/// A `class` representing a `Location`
public struct Location: Wrapped, CustomDebugStringConvertible {
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
    public var wrapper: () -> Wrapper

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
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
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
public struct LocationUnit: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The location.
    public var location: Location? { self["location"].optional().flatMap(Location.init) }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
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
public struct LocationCollection: Wrapped, CustomDebugStringConvertible {
    /// The underlying `Response`.
    public var wrapper: () -> Wrapper

    /// The venues.
    public var venues: [Location]? { self["venues"].array()?.map(Location.init) }
    /// The status.
    public var status: String! { self["status"].string() }

    /// Init.
    /// - parameter wrapper: A valid `Wrapper`.
    public init(wrapper: @escaping () -> Wrapper) {
        self.wrapper = wrapper
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
