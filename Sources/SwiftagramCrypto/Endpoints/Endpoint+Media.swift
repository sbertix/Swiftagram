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
    func archive() -> Endpoint.Single<Status> {
        edit("only_me")
    }

    /// Post a comment under the current post, and optionally under a given comment.
    ///
    /// - parameters:
    ///     - text: A valid `String`.
    ///     - parentCommentIdentifier: An optional `String`. Defaults to `nil`.
    /// - returns: A valid `Endpoint.Single`.
    func comment(with text: String,
                 under parentCommentIdentifier: String? = nil)
    -> Endpoint.Single<Swiftagram.Comment.Unit> {
        .init { secret, requester in
            Request.media(self.identifier)
                .path(appending: "comment/")
                .header(appending: secret.header)
                .signing(body: ["delivery_class": "organic",
                                "feed_position": "0",
                                "container_module": "self_comments_v2_feed_contextual_self_profile",
                                "user_breadcrumb": text.count.breadcrumb,
                                "idempotence_token": UUID().uuidString,
                                "comment_text": text])
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Swiftagram.Comment.Unit.init)
                .requested(by: requester)
        }
    }

    /// Delete the current media.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func delete() -> Endpoint.Single<Status> {
        .init { secret, requester in
            self.summary
                .unlock(with: secret)
                .prepare(with: requester)
                .map { $0["items"][0].mediaType.int() }
                .switch { type -> R.Requested<Status> in
                    // Consider valid media only.
                    guard let mediaType = type, [1, 2, 8].contains(mediaType) else {
                        return R.Once(error: Error.unsupportedType(type), with: requester).requested(by: requester)
                    }
                    // Actually delete the current media.
                    return Request.media(self.identifier)
                        .path(appending: "delete/")
                        .query(appending: mediaType == 2 ? "VIDEO" : "PHOTO", forKey: "media_type")
                        .header(appending: secret.header)
                        .signing(body: [
                            "igtv_feed_preview": false.wrapped,
                            "media_id": self.identifier.wrapped,
                            "_csrftoken": secret["csrftoken"].wrapped,
                            "_uid": secret.identifier.wrapped,
                            "_uuid": secret.client.device.identifier.uuidString.wrapped
                        ] as Wrapper)
                        .prepare(with: requester)
                        .map(\.data)
                        .decode()
                        .map(Status.init)
                        .requested(by: requester)
                }
                .requested(by: requester)
        }
    }

    /// Like the current post.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func like() -> Endpoint.Single<Status> {
        edit("like")
    }

    /// Save in a specific collection.
    ///
    /// - parameter collectionIdentifier: A valid `String`.
    /// - returns: A valid `Endpoint.Single`.
    func save(in collectionIdentifier: String) -> Endpoint.Single<Status> {
        edit("save", body: ["added_collection_ids": "[\(collectionIdentifier)]"])
    }

    /// Unarchive the current post.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unarchive() -> Endpoint.Single<Status> {
        edit("undo_only_me")
    }

    /// Unlike the current post.
    ///
    /// - returns: A valid `Endpoint.Single`.
    func unlike() -> Endpoint.Single<Status> {
        edit("unlike")
    }
}

extension Endpoint.Group.Media {
    /// Perform an action involving the media matching `identifier`.
    ///
    /// - parameters:
    ///     - endpoint: A valid `String`.
    ///     - body: A dictionary of `String`s. Defaults to empty.
    /// - returns: A valid `Endpoint.Single`.
    func edit(_ endpoint: String, body: [String: String] = [:]) -> Endpoint.Single<Status> {
        .init { secret, requester in
            Request.media(self.identifier)
                .path(appending: endpoint)
                .path(appending: "/")
                .header(appending: secret.header)
                .signing(body: ["_csrftoken": secret["csrftoken"],
                                "radio_type": "wifi-none",
                                "_uid": secret.identifier,
                                "device_id": secret.client.device.instagramIdentifier,
                                "_uuid": secret.client.device.identifier.uuidString,
                                "media_id": self.identifier].merging(body) { lhs, _ in lhs })
                .prepare(with: requester)
                .map(\.data)
                .decode()
                .map(Status.init)
                .requested(by: requester)
        }
    }
}
