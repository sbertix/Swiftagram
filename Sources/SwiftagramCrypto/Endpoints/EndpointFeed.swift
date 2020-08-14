//
//  EndpointFeed.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest
import Swiftagram

public extension Endpoint.Feed {
    /// The base endpoint.
    private static let base = Endpoint.version1.feed.appendingDefaultHeader()

    /// All available stories for user matching `identifiers`.
    /// - parameters identifiers: A `Collection` of `String`s holding reference to valud user identifiers.
    static func stories<C: Collection>(by identifiers: C) -> Endpoint.Disposable<Wrapper> where C.Element == String {
        return Endpoint.version1.feed.reels_media
            .appendingDefaultHeader()
            .prepare()
            .locking(Secret.self) {
                $0.appending(header: $1.header)
                    .signing(body: ["_csrftoken": $1.crossSiteRequestForgery.value,
                                    "user_ids": Array(identifiers),
                                    "device_id": $1.device.deviceIdentifier,
                                    "_uid": $1.id,
                                    "_uuid": $1.device.deviceGUID.uuidString,
                                    "supported_capabilities_new": SupportedCapabilities.default.map { ["name": $0.key, "value": $0.value] },
                                    "source": "feed_timeline"])
        }
    }
}
