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
public struct Location: ReflectedType {
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

    /// The debug description prefix.
    public static let debugDescriptionPrefix: String = ""
    /// A list of to-be-reflected properties.
    public static let properties: [String: PartialKeyPath<Self>] = ["coordinates": \Self.coordinates,
                                                                    "name": \Self.name,
                                                                    "shortName": \Self.shortName,
                                                                    "address": \Self.address,
                                                                    "city": \Self.city,
                                                                    "identifier": \Self.identifier]

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
}

public extension Location {
    /// A `struct` representing a single `Location` response.
    struct Unit: ResponseType, ReflectedType {
        /// The prefix.
        public static var debugDescriptionPrefix: String { "Location." }
        /// A list of to-be-reflected properties.
        public static let properties: [String: PartialKeyPath<Self>] = ["location": \Self.location,
                                                                        "error": \Self.error]

        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The location.
        public var location: Location? { self["location"].optional().flatMap(Location.init) }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }

    /// A `struct` representing a `Location` collection.
    struct Collection: ResponseType, PaginatedType, ReflectedType {
        /// The prefix.
        public static var debugDescriptionPrefix: String { "Location." }
        /// A list of to-be-reflected properties.
        public static let properties: [String: PartialKeyPath<Self>] = ["venues": \Self.venues,
                                                                        "pagination": \Self.pagination,
                                                                        "error": \Self.error]
        /// The underlying `Response`.
        public var wrapper: () -> Wrapper

        /// The venues.
        public var venues: [Location]? { self["venues"].array()?.map(Location.init) }

        /// Init.
        /// - parameter wrapper: A valid `Wrapper`.
        public init(wrapper: @escaping () -> Wrapper) {
            self.wrapper = wrapper
        }
    }
}
