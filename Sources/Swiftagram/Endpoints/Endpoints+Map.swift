//
//  Endpoints+Map.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 01/04/21.
//

import Foundation

public extension Endpoints.Map {
    /// Fetch all locations near a given point,
    /// matching some optional query.
    ///
    /// - parameters:
    ///     - coordinates: A tuple of `Double`s.
    ///     - query: An optional `String`. Defaults to `nil`.
    /// - returns: Some locked `Endpoint`.
    static func locations(
        near coordinates: (latitude: Double, longitude: Double),
        matching query: String? = nil
    ) -> Endpoint.Single<AnyDecodable> {
        let rank: UUID = .init()
        return .init { secret in
            Single {
                Path("https://i.instagram.com/api/v1/location_search/")
                Headers() // Default headers.
                Headers(secret.header)
                Query([
                    "rank_token": rank.uuidString,
                    "latitude": "\(coordinates.latitude)",
                    "longitude": "\(coordinates.longitude)",
                    "timestamp": query == nil ? "\(Int(Date().timeIntervalSince1970 * 1_000))" : nil,
                    "search_query": query,
                    "_csrftoken": secret["csrftoken"],
                    "_uid": secret.identifier,
                    "_uuid": secret.client.device.identifier.uuidString
                ])
                Response(AnyDecodable.self) // Location.Collection
            }.eraseToAnySingleEndpoint()
        }
    }
}
