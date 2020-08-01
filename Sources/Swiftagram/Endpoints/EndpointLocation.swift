//
//  EndpointLocation.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A `struct` holding reference to `location` `Endpoint`s. Requires authentication.
    struct Location {
        /// Get locations around coordinates.
        /// - parameters:
        ///     - coordinates: A `CGPoint` with latitude and longitude.
        ///     - query: An optional `String` narrowing down the list. Defaults to `nil`.
        public static func around(coordinates: Swiftagram.Location.Coordinates, matching query: String? = nil) -> Disposable<LocationCollection> {
            return Endpoint.version1
                .appendingDefaultHeader()
                .appending(path: "location_search/")
                .appending(query: [
                    "rank_token": "",
                    "latitude": "\(coordinates.latitude)",
                    "longitude": "\(coordinates.longitude)",
                    "timestamp": query == nil ? "\(Int(Date().timeIntervalSince1970*1_000))" : nil,
                    "search_query": query
                ])
                .prepare(process: LocationCollection.self)
                .locking(Secret.self) {
                    $0.appending(header: $1.header)
                        .appending(query: [
                            "_csrftoken": $1.crossSiteRequestForgery.value,
                            "_uid": $1.id,
                            "_uuid": $1.device.deviceGUID.uuidString
                        ])
                }
        }
    }
}
