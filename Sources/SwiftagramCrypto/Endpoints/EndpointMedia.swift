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
    static func like(_ identifier: String) -> Endpoint.ResponseDisposable {
        return Posts.like(identifier)
    }

    /// Unlike the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    @available(*, deprecated, message: "use `Endpoint.Media.Posts.unlike(_:)`")
    static func unlike(_ identifier: String) -> Endpoint.ResponseDisposable {
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

    #if canImport(UIKit)
    /// Upload `image` to Instagram.
    /// - parameters:
    ///     - image: A `UIImage` representation of an image.
    ///     - caption: An optional `String` holding the post's caption.
    static func upload(image: UIImage, caption: String?) -> Endpoint.ResponseDisposable {
        guard let data = image.jpegData(compressionQuality: 1) else { fatalError("Invalid `UIImage`.") }
        return upload(image: data, size: image.size, caption: caption)
    }
    #endif
    #if canImport(AppKit)
    /// Upload `image` to Instagram.
    /// - parameters:
    ///     - image: A `NSImage` representation of an image.
    ///     - caption: An optional `String` holding the post's caption.
    static func upload(image: NSImage, caption: String?) -> Endpoint.ResponseDisposable {
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
                       caption: String?) -> Endpoint.ResponseDisposable {
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
                        .appending(header: "IG-U-DS-User-ID", with: $1.identifier)
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
                    "device": try? Response.description(for: $1.device.payload) as Any,
                    "_csrftoken": $1.crossSiteRequestForgery.value,
                    "user_id": identifier,
                    "_uid": $1.identifier ?? "",
                    "device_id": $1.device.deviceIdentifier,
                    "_uuid": $1.device.deviceGUID.uuidString
                ].compactMapValues { $0 }
                // Configure.
                return $0.appending(header: $1.header)
                    .signing(body: Response(body))
            }
    }
}
