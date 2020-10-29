//
//  EndpointHighlights.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 04/07/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A `struct` holding reference to `highlights` `Endpoint`s. Requires authentication.
    struct Highlights {
        /// The base endpoint.
        private static let base = Endpoint.version1.highlights.appendingDefaultHeader()

        /// Return the highlights tray for a specific user.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        /// - warning: This method will be removed in `4.2.0`.
        @available(
            *,
            deprecated,
            message: "use `Endpoint.Media.Stories.highlights(for:)` instead"
        )
        public static func tray(for identifier: String) -> Disposable<TrayItem.Collection> {
            return base.appending(path: identifier).highlights_tray
                .prepare(process: TrayItem.Collection.self)
                .locking(Secret.self) {
                    $0.appending(query: [
                        "supported_capabilities_new": try? SupportedCapabilities
                            .default
                            .map { ["name": $0.key, "value": $0.value] }
                            .wrapped
                            .jsonRepresentation(),
                        "phone_id": $1.client.device.phoneIdentifier.uuidString,
                        "battery_level": "72",
                        "is_charging": "0",
                        "will_sound_on": "0"
                    ]).appending(header: $1.header)
            }
        }
    }
}
