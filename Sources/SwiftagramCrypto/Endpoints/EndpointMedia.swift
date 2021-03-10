//
//  EndpointFeed.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

import ComposableRequest
import Swiftagram

/// An `enum` listing media-related error.
enum MediaError: Error {
    /// Artifcat.
    case artifact(Wrapper)
    /// Offensive comment.
    case offensiveComment
    /// Unsupported type.
    case unsupportedType(Int?)
    /// Video not found.
    case videoNotFound
    /// Video too long.
    case videoTooLong(seconds: TimeInterval)
}

public extension Endpoint.Media {
    /// The base endpoint.
    private static let base = Endpoint.version1.media.appendingDefaultHeader()

    /// Delete the media matching `identifier`.
    ///
    /// - parameter identifier: A valid media identifier.
    /// - note: **SwiftagramCrypto** only.
    static func delete(_ identifier: String) -> Endpoint.Disposable<Status, Error> {
        .init { secret, session in
            Deferred {
                base.path(appending: identifier)
                    .info
                    .header(appending: secret.header)
                    .project(session)
                    .map(\.data)
                    .wrap()
                    .map { $0["items"][0].mediaType.int() }
                    .flatMap { type -> AnyPublisher<Request.Response, Error> in
                        guard let mediaType = type, [1, 2, 8].contains(mediaType) else {
                            return Fail(error: MediaError.unsupportedType(type)).eraseToAnyPublisher()
                        }
                        return base.path(appending: identifier)
                            .path(appending: "delete/")
                            .query(appending: mediaType == 2 ? "VIDEO" : "PHOTO", forKey: "media_type")
                            .header(appending: secret.header)
                            .signing(body: [
                                "igtv_feed_preview": false.wrapped,
                                "media_id": identifier.wrapped,
                                "_csrftoken": secret["csrftoken"]!.wrapped,
                                "_uid": secret.identifier.wrapped,
                                "_uuid": secret.client.device.identifier.uuidString.wrapped
                            ] as Wrapper)
                            .project(session)
                    }
                    .map(\.data)
                    .wrap()
                    .map(Status.init)
            }
            .receive(on: session.scheduler)
            .eraseToAnyPublisher()
        }
    }
}
