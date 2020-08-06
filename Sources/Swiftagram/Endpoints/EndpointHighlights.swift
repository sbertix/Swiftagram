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
        public static func tray(for identifier: String) -> Disposable<TrayItemCollection> {
            return base.appending(path: identifier).highlights_tray
                .prepare(process: TrayItemCollection.self)
                .locking(Secret.self) {
                    $0.appending(query: [
                        "supported_capabilities_new": try? Response.description(for:
                            SupportedCapabilities.default.map { ["name": $0.key, "value": $0.value]
                        }),
                        "phone_id": $1.device.phoneGUID.uuidString,
                        "battery_level": "72",
                        "is_charging": "0",
                        "will_sound_on": "0"
                    ]).appending(header: $1.header)
            }
        }

        // MARK: Deprecated
        /// Return the highlights tray for a specific user.
        /// - parameter identifier: A `String` holding reference to a valid user identifier.
        @available(*, deprecated, renamed: "tray")
        public static func highlights(for identifier: String) -> Disposable<TrayItemCollection> {
            return tray(for: identifier)
        }
    }
}
