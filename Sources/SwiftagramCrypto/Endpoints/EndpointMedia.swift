//
//  EndpointFeed.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest
import Swiftagram

public extension Endpoint.Media {
    /// The base endpoint.
    private static let base = Endpoint.version1.media.appendingDefaultHeader()

    // MARK: Actions
    /// Perform an action involving the media matching `identifier`.
    /// - parameters:
    ///     - transformation: A `KeyPath` defining the endpoint path.
    ///     - identifier: A `String` holding reference to a valid user identifier.
    private static func edit(_ keyPath: KeyPath<Request, Request>, _ identifier: String) -> Endpoint.ResponseDisposable {
        return base
            .appending(path: identifier)[keyPath: keyPath]
            .appending(path: "/")
            .prepare()
            .locking(Secret.self) {
                $0.appending(header: $1.header)
                    .signing(body: ["_csrftoken": $1.crossSiteRequestForgery.value,
                                    "radio_type": "wifi-none",
                                    "_uid": $1.identifier ?? "",
                                    "device_id": $1.device.deviceIdentifier,
                                    "_uuid": $1.device.deviceGUID.uuidString,
                                    "media_id": identifier])
        }
    }

    /// Like the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    static func like(_ identifier: String) -> Endpoint.ResponseDisposable {
        return edit(\.like, identifier)
    }

    /// Unlike the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    static func unlike(_ identifier: String) -> Endpoint.ResponseDisposable {
        return edit(\.unlike, identifier)
    }
}
