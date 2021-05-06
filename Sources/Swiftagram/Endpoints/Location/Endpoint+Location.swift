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
    static func location(_ identifier: String) -> Endpoint.Single<Swiftagram.Location.Unit, Error> {
        location(identifier).summary
    }

    /// A list of locations around the given coordiantes, matching an optional query.
    ///
    /// - parameters:
    ///     - coordinates: Some valid `Location.Coordinates`.
    ///     - query: An optional `String`. Defaults to `nil`.
    /// - returns: A valid `Endpoint.Single`.
    static func locations(around coordinates: Swiftagram.Location.Coordinates,
                          matching query: String? = nil) -> Endpoint.Single<Swiftagram.Location.Collection, Error> {
        .init { secret, session in
            Deferred {
                Request.version1
                    .appendingDefaultHeader()
                    .path(appending: "location_search/")
                    .header(appending: secret.header)
                    .query(appending: [
                        "rank_token": "",
                        "latitude": "\(coordinates.latitude)",
                        "longitude": "\(coordinates.longitude)",
                        "timestamp": query == nil ? "\(Int(Date().timeIntervalSince1970*1_000))" : nil,
                        "search_query": query,
                        "_csrftoken": secret["csrftoken"]!,
                        "_uid": secret.identifier,
                        "_uuid": secret.client.device.identifier.uuidString
                    ])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Location.Collection.init)
            }
            .eraseToAnyPublisher()
        }
    }
}

extension Request {
    /// A locations related request.
    static let locations = Request.version1.locations.appendingDefaultHeader()

    /// A location related request.
    ///
    /// - parameter location: A valid `Endpoint.Location`.
    /// - returns: A valid `Request`.
    static func location(_ location: Endpoint.Group.Location) -> Request {
        locations.path(appending: location.identifier)
    }
}

public extension Endpoint.Group.Location {
    /// A summary for the current location.
    ///
    /// - note: Prefer `Endpoint.location(_:)` instead.
    var summary: Endpoint.Single<Swiftagram.Location.Unit, Error> {
        .init { secret, session in
            Deferred {
                Request.location(self)
                    .path(appending: "info/")
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Location.Unit.init)
            }
            .replaceFailingWithError()
        }
    }

    /// A list of some recent stories at the current location.
    var stories: Endpoint.Single<TrayItem.Unit, Error> {
        .init { secret, session in
            Deferred {
                Request.location(self)
                    .path(appending: "story/")
                    .appendingDefaultHeader()
                    .header(appending: secret.header)
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(TrayItem.Unit.init)
            }
            .replaceFailingWithError()
        }
    }
}
