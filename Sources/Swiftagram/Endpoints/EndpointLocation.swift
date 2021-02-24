//
//  EndpointLocation.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A module-like `enum` holding reference to `location` `Endpoint`s. Requires authentication.
    enum Location {
        /// Get locations around coordinates.
        ///
        /// - parameters:
        ///     - coordinates: A `CGPoint` with latitude and longitude.
        ///     - query: An optional `String` narrowing down the list. Defaults to `nil`.
        public static func around(coordinates: Swiftagram.Location.Coordinates,
                                  matching query: String? = nil) -> Disposable<Swiftagram.Location.Collection, Error> {
            .init { secret, session in
                Projectables.Deferred {
                    Endpoint.version1
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
                        .project(session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.Location.Collection.init)
                }
                .observe(on: session.scheduler)
                .eraseToAnyObservable()
            }
        }

        /// Get the summary for the location matching `identifier`.
        ///
        /// - parameter identifier: A valid location identifier.
        public static func summary(for identifier: String) -> Disposable<Swiftagram.Location.Unit, Error> {
            .init { secret, session in
                Projectables.Deferred {
                    Endpoint.version1
                        .locations
                        .path(appending: identifier)
                        .path(appending: "info/")
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .project(session)
                        .map(\.data)
                        .wrap()
                        .map(Swiftagram.Location.Unit.init)
                }
                .observe(on: session.scheduler)
                .eraseToAnyObservable()
            }
        }

        /// Fetch stories currently available at the location matching `identifier`.
        ///
        /// - parameter identifier: A valid location identifier.
        public static func stories(at identifier: String) -> Disposable<TrayItem.Unit, Error> {
            .init { secret, session in
                Projectables.Deferred {
                    Endpoint.version1
                        .locations
                        .path(appending: identifier)
                        .path(appending: "story/")
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .project(session)
                        .map(\.data)
                        .wrap()
                        .map(TrayItem.Unit.init)
                }
                .observe(on: session.scheduler)
                .eraseToAnyObservable()
            }
        }
    }
}
