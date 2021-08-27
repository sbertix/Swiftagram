//
//  Endpoint+Location.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 01/04/21.
//

import Foundation

public extension Endpoint.Group {
    /// A `class` defining location endpoints.
    final class Location {
        /// The location identifier.
        public let identifier: String

        /// Init.
        ///
        /// - parameter identifier: A valid `String`.
        init(identifier: String) {
            self.identifier = identifier
        }
    }
}

public extension Endpoint {
    /// A wrapper for location endpoints.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Location`.
    static func location(_ identifier: String) -> Endpoint.Group.Location {
        .init(identifier: identifier)
    }

    /// A summary for the location media.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    static func location(_ identifier: String) -> Endpoint.Single<Swiftagram.Location.Unit> {
        location(identifier).summary
    }

    /// A list of locations around the given coordiantes, matching an optional query.
    ///
    /// - parameters:
    ///     - coordinates: Some valid `Location.Coordinates`.
    ///     - query: An optional `String`. Defaults to `nil`.
    /// - returns: A valid `Endpoint.Single`.
    static func locations(around coordinates: Swiftagram.Location.Coordinates,
                          matching query: String? = nil) -> Endpoint.Single<Swiftagram.Location.Collection> {
        .init { secret, requester in
            Request.version1
                .appendingDefaultHeader()
                .path(appending: "location_search/")
                .header(appending: secret.header)
                .query(appending: [
                    "rank_token": "",
                    "latitude": "\(coordinates.latitude)",
                    "longitude": "\(coordinates.longitude)",
                    "timestamp": query == nil ? "\(Int(Date().timeIntervalSince1970 * 1_000))" : nil,
                    "search_query": query,
                    "_csrftoken": secret["csrftoken"],
                    "_uid": secret.identifier,
                    "_uuid": secret.client.device.identifier.uuidString
                ])
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Swiftagram.Location.Collection.init)
                .requested(by: requester)
        }
    }
}

extension Request {
    /// A locations related request.
    static let locations = Request.version1.locations.appendingDefaultHeader()

    /// A location related request.
    ///
    /// - parameter location: A valid `Endpoint.Location` identifier.
    /// - returns: A valid `Request`.
    static func location(_ location: String) -> Request {
        locations.path(appending: location)
    }
}

public extension Endpoint.Group.Location {
    /// A summary for the current location.
    ///
    /// - note: Prefer `Endpoint.location(_:)` instead.
    var summary: Endpoint.Single<Swiftagram.Location.Unit> {
        .init { secret, requester in
            Request.location(self.identifier)
                .path(appending: "info/")
                .appendingDefaultHeader()
                .header(appending: secret.header)
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Swiftagram.Location.Unit.init)
                .requested(by: requester)
        }
    }

    /// A list of some recent stories at the current location.
    var stories: Endpoint.Single<TrayItem.Unit> {
        .init { secret, requester in
            Request.location(self.identifier)
                .path(appending: "story/")
                .appendingDefaultHeader()
                .header(appending: secret.header)
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(TrayItem.Unit.init)
                .requested(by: requester)
        }
    }
}
