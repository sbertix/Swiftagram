//
//  Endpoint+Media.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 07/04/21.
//

import Foundation

extension Request {
    /// The media request.
    static let media = Request.version1.media.appendingDefaultHeader()

    /// A specific media request.
    ///
    /// - parameter identifier: A valid `String`.
    /// - returns: A valid `Request`.
    static func media(_ identifier: String) -> Request {
        Request.media.path(appending: identifier)
    }
}

public extension Endpoint.Group.Media {
    /// Archive the current post.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func archive() -> Endpoint.Single<Status, Swift.Error> {
        edit("only_me")
    }

    /// Post a comment under the current post, and optionally under a given comment.
    ///
    /// - parameters:
    ///     - text: A valid `String`.
    ///     - parentCommentIdentifier: An optional `String`. Defaults to `nil`.
    /// - returns: A valid `Endpoint.Single`.
    func comment(with text: String,
                 under parentCommentIdentifier: String? = nil) -> Endpoint.Single<Swiftagram.Comment.Unit, Swift.Error> {
        .init { secret, session in
            Deferred {
                Request.media(self.identifier)
                    .path(appending: "comment/")
                    .header(appending: secret.header)
                    .signing(body: ["delivery_class": "organic",
                                    "feed_position": "0",
                                    "container_module": "self_comments_v2_feed_contextual_self_profile",
                                    "user_breadcrumb": text.count.breadcrumb,
                                    "idempotence_token": UUID().uuidString,
                                    "comment_text": text])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Swiftagram.Comment.Unit.init)
            }
            .eraseToAnyPublisher()
        }
    }

    /// Delete the current media.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func delete() -> Endpoint.Single<Status, Swift.Error> {
        .init { secret, session in
            self.summary
                .unlock(with: secret)
                .session(session)
                .map { $0["items"][0].mediaType.int() }
                .flatMap { type -> AnyPublisher<Status, Swift.Error> in
                    // Consider valid media only.
                    guard let mediaType = type, [1, 2, 8].contains(mediaType) else {
                        return Fail(error: Error.unsupportedType(type)).eraseToAnyPublisher()
                    }
                    // Actually delete the current media.
                    return Request.media(self.identifier)
                        .path(appending: "delete/")
                        .query(appending: mediaType == 2 ? "VIDEO" : "PHOTO", forKey: "media_type")
                        .header(appending: secret.header)
                        .signing(body: [
                            "igtv_feed_preview": false.wrapped,
                            "media_id": self.identifier.wrapped,
                            "_csrftoken": secret["csrftoken"]!.wrapped,
                            "_uid": secret.identifier.wrapped,
                            "_uuid": secret.client.device.identifier.uuidString.wrapped
                        ] as Wrapper)
                        .publish(with: session)
                        .map(\.data)
                        .wrap()
                        .map(Status.init)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
    }

    /// Like the current post.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func like() -> Endpoint.Single<Status, Swift.Error> {
        edit("like")
    }

    /// Unarchive the current post.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unarchive() -> Endpoint.Single<Status, Swift.Error> {
        edit("undo_only_me")
    }

    /// Unlike the current post.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unlike() -> Endpoint.Single<Status, Swift.Error> {
        edit("unlike")
    }
}

extension Endpoint.Group.Media {
    /// Perform an action involving the media matching `identifier`.
    ///
    /// - parameter endpoint: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    func edit(_ endpoint: String) -> Endpoint.Single<Status, Swift.Error> {
        .init { secret, session in
            Deferred {
                Request.media(self.identifier)
                    .path(appending: endpoint)
                    .path(appending: "/")
                    .header(appending: secret.header)
                    .signing(body: ["_csrftoken": secret["csrftoken"]!,
                                    "radio_type": "wifi-none",
                                    "_uid": secret.identifier,
                                    "device_id": secret.client.device.instagramIdentifier,
                                    "_uuid": secret.client.device.identifier.uuidString,
                                    "media_id": self.identifier])
                    .publish(with: session)
                    .map(\.data)
                    .wrap()
                    .map(Status.init)
            }
            .eraseToAnyPublisher()
        }
    }
}
