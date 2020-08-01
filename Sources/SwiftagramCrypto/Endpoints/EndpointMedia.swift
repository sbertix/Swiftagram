//
//  EndpointFeed.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

import ComposableRequest
import Swiftagram

public extension Endpoint.Media {
    /// Like the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    @available(*, deprecated, message: "use `Endpoint.Media.Posts.like(_:)`")
    static func like(_ identifier: String) -> Endpoint.Disposable<Status> {
        return Posts.like(identifier)
    }

    /// Unlike the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    @available(*, deprecated, message: "use `Endpoint.Media.Posts.unlike(_:)`")
    static func unlike(_ identifier: String) -> Endpoint.Disposable<Status> {
        return Posts.unlike(identifier)
    }
}

public extension Endpoint.Media.Posts {
    /// The base endpoint.
    private static let base = Endpoint.version1.media.appendingDefaultHeader()

    // MARK: Actions
    /// Perform an action involving the media matching `identifier`.
    /// - parameters:
    ///     - transformation: A `KeyPath` defining the endpoint path.
    ///     - identifier: A `String` holding reference to a valid user identifier.
    private static func edit(_ keyPath: KeyPath<Request, Request>, _ identifier: String) -> Endpoint.Disposable<Status> {
        return base
            .appending(path: identifier)[keyPath: keyPath]
            .appending(path: "/")
            .prepare(process: Status.self)
            .locking(Secret.self) {
                $0.appending(header: $1.header)
                    .signing(body: ["_csrftoken": $1.crossSiteRequestForgery.value,
                                    "radio_type": "wifi-none",
                                    "_uid": $1.id,
                                    "device_id": $1.device.deviceIdentifier,
                                    "_uuid": $1.device.deviceGUID.uuidString,
                                    "media_id": identifier])
        }
    }

    /// Like the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    static func like(_ identifier: String) -> Endpoint.Disposable<Status> {
        return edit(\.like, identifier)
    }

    /// Unlike the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    static func unlike(_ identifier: String) -> Endpoint.Disposable<Status> {
        return edit(\.unlike, identifier)
    }

    /// Archive the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    static func archive(_ identifier: String) -> Endpoint.Disposable<Status> {
        return edit(\.only_me, identifier)
    }

    /// Unarchive the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    static func unarchive(_ identifier: String) -> Endpoint.Disposable<Status> {
        return edit(\.undo_only_me, identifier)
    }

    /// Comment on the media matching `identifier`.
    /// - parameters:
    ///     - text: A `String` holding the content of the comment.
    ///     - identifier: A valid media identifier.
    ///     - parentCommentIdentifier: An optional `String` representing the identifier for the comment you are replying to. Defaults to `nil`.
    static func comment(_ text: String,
                        on identifier: String,
                        replyingTo parentCommentIdentifier: String? = nil) -> Endpoint.Disposable<Status> {
        return base.comment.appending(path: "check_offensive_comment/")
            .prepare(process: Status.self)
            .switch {
                guard (try? $0.get().response().isOffensive.bool()) == false else { return nil }
                return base.appending(path: identifier)
                    .appending(path: "comment/")
            }
            .locking(Secret.self) {
                // Check whether you are posting orjust checking for offensive comments.
                guard !$0.url.absoluteString.contains("check_offensive_comment") else {
                    return $0.appending(header: $1.header)
                        .signing(body: [
                            "_csrftoken": $1.crossSiteRequestForgery.value,
                            "_uid": $1.id,
                            "_uuid": $1.device.deviceGUID.uuidString,
                            "media_id": identifier,
                            "comment_text": text
                        ])
                }
                // Post the actual comment.
                return $0.appending(header: $1.header)
                    .signing(body: ([
                        "user_breadcrumb": text.count.breadcrumb,
                        "_csrftoken": $1.crossSiteRequestForgery.value,
                        "radio_type": "wifi-none",
                        "_uid": $1.id,
                        "device_id": $1.device.deviceIdentifier,
                        "_uuid": $1.device.deviceGUID.uuidString,
                        "media_id": identifier,
                        "comment_text": text,
                        "containermodule": "self_comments_v2",
                        "replied_to_comment_id": parentCommentIdentifier
                    ] as [String: String?]).compactMapValues { $0 })
            }
    }

    /// Delete the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    static func delete(matching identifier: String) -> Endpoint.Disposable<Status> {
        return base
            .appending(path: identifier)
            .info
            .prepare(process: Status.self)
            .switch {
                guard let type = (try? $0.get())?["items"][0].mediaType.int(), [1, 2, 8].contains(type) else { return nil }
                return base.appending(path: identifier)
                    .appending(path: "delete/")
                    .appending(query: "media_type",
                               with: type == 1
                               ? "PHOTO"
                               : type == 2 ? "VIDEO" : "CAROUSEL")
            }
            .locking(Secret.self) {
                // Unlock when dealing with the first call.
                guard $0.request()?.url?.absoluteString.contains("delete") ?? false else {
                    return $0.appending(header: $1.header)
                }

                // Sign the body.
                return $0.appending(header: $1.header)
                    .signing(body: Response([
                    "igtv_feed_preview": false,
                    "media_id": identifier,
                    "_csrftoken": $1.crossSiteRequestForgery.value,
                    "_uid": $1.id,
                    "_uuid": $1.device.deviceGUID.uuidString
                ]))
            }
    }

    #if canImport(UIKit)
    /// Upload `image` to Instagram.
    /// - parameters:
    ///     - image: A `UIImage` representation of an image.
    ///     - caption: An optional `String` holding the post's caption.
    static func upload(image: UIImage, caption: String?) -> Endpoint.DisposableResponse {
        guard let data = image.jpegData(compressionQuality: 1) else { fatalError("Invalid `UIImage`.") }
        return upload(image: data, size: image.size, caption: caption)
    }
    #endif
    #if canImport(AppKit)
    /// Upload `image` to Instagram.
    /// - parameters:
    ///     - image: A `NSImage` representation of an image.
    ///     - caption: An optional `String` holding the post's caption.
    static func upload(image: NSImage, caption: String?) -> Endpoint.DisposableResponse {
        guard let data = image.tiffRepresentation else { fatalError("Invalid `UIImage`.") }
        return upload(image: data, size: image.size, caption: caption)
    }
    #endif

    /// Upload `image` to Instagram.
    /// - parameters:
    ///     - image: A `Data` representation of an image.
    ///     - size: A `CGSize` holding `width` and `height` of the original image.
    ///     - caption: An optional `String` holding the post's caption.
    static func upload(image data: Data,
                       size: CGSize,
                       caption: String?) -> Endpoint.DisposableResponse {
        /// Prepare upload parameters.
        let now = Date()
        let identifier = String(Int(now.timeIntervalSince1970*1_000))
        let name = identifier+"_0_\(Int.random(in: 1_000_000_000...9_999_999_999))"
        let length = "\(data.count)"
        /// Prepare the header.
        let rupload = [
            "retry_context": #"{"num_step_auto_retry":0,"num_reupload":0,"num_step_manual_retry":0}"#,
            "media_type": "1",
            "upload_id": identifier,
            "xsharing_user_ids": "[]",
            "image_compression": #"{"lib_name":"moz","lib_version":"3.1.m","quality":"80"}"#
        ]
        let header = [
            "X_FB_PHOTO_WATERFALL_ID": UUID().uuidString,
            "X-Entity-Type": "image/jpeg",
            "Offset": "0",
            "X-Instagram-Rupload-Params": try? Response.description(for: rupload),
            "X-Entity-Name": name,
            "X-Entity-Length": length,
            "Content-Type": "application/octet-stream",
            "Content-Length": length,
            "Accept-Encoding": "gzip"
        ]
        /// Return the first endpoint.
        return Endpoint.api
            .appending(path: "rupload_igphoto")
            .appending(path: name)
            .appendingDefaultHeader()
            .appending(header: header)
            .replacing(body: data)
            .prepare()
            .switch {
                // Configure the picture you've just updated.
                guard let response = try? $0.get(), response.status.string() == "ok" else { return nil }
                print(response)
                // The actual configuration will be performed by the preprocessor on `unlocking`.
                return base.appending(path: "configure/")
            }
            .locking(Secret.self) {
                // Unlock when dealing with the first call.
                guard $0.request()?.url?.absoluteString.contains("configure") ?? false else {
                    return $0.appending(header: $1.header)
                        .appending(header: "IG-U-DS-User-ID", with: $1.id)
                }

                // Prepare the configuration request.
                // Prepare edits and extras.
                let edits: [String: Any] = [
                    "crop_original_size": [Int(size.width), Int(size.height)],
                    "crop_center": [0.0, -0.0],
                    "crop_zoom": 1.0
                ]
                let extras: [String: Any] = [
                    "source_width": Int(size.width),
                    "source_height": Int(size.height)
                ]
                // Prepare the body.
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy:MM:dd' 'HH:mm:ss"
                let formattedNow = formatter.string(from: now)
                let body: [String: Any] = [
                    "upload_id": identifier,
                    "width": Int(size.width),
                    "height": Int(size.height),
                    "caption": caption ?? "",
                    "timezone_offset": "43200",
                    "date_time_original": formattedNow,
                    "date_time_digitalized": formattedNow,
                    "source_type": "4",
                    "media_folder": "Instagram",
                    "edits": edits,
                    "extra": extras,
                    "camera_model": $1.device.model,
                    "scene_capture_type": "standard",
                    "creation_logger_session_id": $1.session.value,
                    "software": "1",
                    "camera_make": $1.device.brand,
                    "device": (try? Response.description(for: $1.device.payload)) as Any,
                    "_csrftoken": $1.crossSiteRequestForgery.value,
                    "user_id": identifier,
                    "_uid": $1.id,
                    "device_id": $1.device.deviceIdentifier,
                    "_uuid": $1.device.deviceGUID.uuidString
                ].compactMapValues { $0 }
                // Configure.
                return $0.appending(header: $1.header)
                    .signing(body: Response(body))
            }
    }
}
