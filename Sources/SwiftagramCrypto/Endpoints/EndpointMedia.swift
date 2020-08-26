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
    /// The base endpoint.
    private static let base = Endpoint.version1.media.appendingDefaultHeader()

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
                               with: type == 2 ? "VIDEO" : "PHOTO")
            }
            .locking(Secret.self) {
                // Unlock when dealing with the first call.
                guard $0.request()?.url?.absoluteString.contains("delete") ?? false else {
                    return $0.appending(header: $1.header)
                }

                // Sign the body.
                return $0.appending(header: $1.header)
                    .signing(body: [
                        "igtv_feed_preview": Wrapper(booleanLiteral: false),
                        "media_id": Wrapper(stringLiteral: identifier),
                        "_csrftoken": Wrapper(stringLiteral: $1.crossSiteRequestForgery.value),
                        "_uid": Wrapper(stringLiteral: $1.id),
                        "_uuid": Wrapper(stringLiteral: $1.device.deviceGUID.uuidString)
                    ] as Wrapper)
            }
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
                guard (try? $0.get().wrapper().isOffensive.bool()) == false else { return nil }
                return base.appending(path: identifier).appending(path: "comment/")
            }
            .locking(Secret.self) {
                // Figure out whether you are posting or just checking for offensive comments.
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

    /// Delete all matching comments in media matching `identifier`.
    /// - parameters:
    ///     - commentIdentifiers: A collection of `String` representing comment identifiers.
    ///     - identifier: A valid media identifier.
    static func delete<C: Collection>(comments commentIdentifiers: C,
                                      on identifier: String) -> Endpoint.Disposable<Status> where C.Element == String {
        return base
            .appending(path: identifier)
            .appending(path: "comment/bulk_delete/")
            .prepare(process: Status.self)
            .locking(Secret.self) {
                $0.appending(header: $1.header)
                    .signing(body: [
                        "comment_ids_to_delete": commentIdentifiers.joined(separator: ","),
                        "_csrftoken": $1.crossSiteRequestForgery.value,
                        "_uid": $1.id,
                        "_uuid": $1.device.deviceGUID.uuidString
                    ])
            }
    }

    #if canImport(UIKit)
    /// Upload `image` to Instagram.
    /// - parameters:
    ///     - image: A `UIImage` representation of an image.
    ///     - caption: An optional `String` holding the post's caption.
    ///     - users: An optional collection of `UserTag`s. Defaults to `nil`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload<U: Collection>(image: UIImage,
                                      captioned caption: String?,
                                      tagging users: U?,
                                      at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> where U.Element == UserTag {
        guard let data = image.jpegData(compressionQuality: 1) else { fatalError("Invalid `UIImage`.") }
        return upload(image: data, size: image.size, captioned: caption, tagging: users, at: location)
    }

    /// Upload `image` to Instagram.
    /// - parameters:
    ///     - image: A `UIImage` representation of an image.
    ///     - caption: An optional `String` holding the post's caption.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload(image: UIImage,
                       captioned caption: String?,
                       at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> {
        return upload(image: image, captioned: caption, tagging: [], at: location)
    }
    #endif
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// Upload `image` to Instagram.
    /// - parameters:
    ///     - image: A `NSImage` representation of an image.
    ///     - caption: An optional `String` holding the post's caption.
    ///     - users: An optional collection of `UserTag`s. Defaults to `nil`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload<U: Collection>(image: NSImage,
                                      captioned caption: String?,
                                      tagging users: U?,
                                      at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> where U.Element == UserTag {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
            let data = NSBitmapImageRep(cgImage: cgImage).representation(using: .jpeg, properties: [:]) else {
                fatalError("Invalid `UIImage`.")
        }
        return upload(image: data, size: image.size, captioned: caption, tagging: users, at: location)
    }

    /// Upload `image` to Instagram.
    /// - parameters:
    ///     - image: A `NSImage` representation of an image.
    ///     - caption: An optional `String` holding the post's caption.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload(image: NSImage,
                       captioned caption: String?,
                       at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> {
        return upload(image: image, captioned: caption, tagging: [], at: location)
    }
    #endif

    /// Upload `image` to Instagram.
    /// - parameters:
    ///     - image: A `Data` representation of an image.
    ///     - size: A `CGSize` holding `width` and `height` of the original image.
    ///     - caption: An optional `String` holding the post's caption.
    ///     - users: An optional collection of `UserTag`s. Defaults to `nil`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload<U: Collection>(image data: Data,
                                      size: CGSize,
                                      captioned caption: String?,
                                      tagging users: U?,
                                      at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> where U.Element == UserTag {
        /// Prepare upload parameters.
        let now = Date()
        let identifier = String(Int(now.timeIntervalSince1970*1_000))
        let name = identifier+"_0_\(Int64.random(in: 1_000_000_000...9_999_999_999))"
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
            "X-Instagram-Rupload-Params": try? rupload.wrapped.jsonRepresentation(),
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
            .prepare(process: Media.Unit.self)
            .switch {
                // Configure the picture you've just updated.
                guard let response = try? $0.get(), response.error == nil else { return nil }
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
                let edits: Wrapper = [
                    "crop_original_size": [Int(size.width), Int(size.height)].wrapped,
                    "crop_center": [0.0, -0.0],
                    "crop_zoom": 1.0
                ]
                let extras: Wrapper = [
                    "source_width": Int(size.width).wrapped,
                    "source_height": Int(size.height).wrapped
                ]
                // Prepare the body.
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy:MM:dd' 'HH:mm:ss"
                let formattedNow = formatter.string(from: now)
                var body: Wrapper = [
                    "upload_id": identifier.wrapped,
                    "width": Int(size.width).wrapped,
                    "height": Int(size.height).wrapped,
                    "caption": (caption ?? "").wrapped,
                    "timezone_offset": "43200",
                    "date_time_original": formattedNow.wrapped,
                    "date_time_digitalized": formattedNow.wrapped,
                    "source_type": "4",
                    "media_folder": "Instagram",
                    "edits": edits,
                    "extra": extras,
                    "camera_model": $1.device.model.wrapped,
                    "scene_capture_type": "standard",
                    "creation_logger_session_id": $1.session!.value.wrapped,
                    "software": "1",
                    "camera_make": $1.device.brand.wrapped,
                    "device": (try? $1.device.payload.wrapped.jsonRepresentation()).wrapped,
                    "_csrftoken": $1.crossSiteRequestForgery.value.wrapped,
                    "user_id": identifier.wrapped,
                    "_uid": $1.id.wrapped,
                    "device_id": $1.device.deviceIdentifier.wrapped,
                    "_uuid": $1.device.deviceGUID.uuidString.wrapped
                ]
                if let users = users?.compactMap({ UserTag.request($0) }),
                    !users.isEmpty,
                    let description = try? ["in": users.wrapped].wrapped.jsonRepresentation() {
                    body["usertags"] = description.wrapped
                }
                // Add location.
                if let location = location {
                    body["location"] = ["name": location.name.wrapped,
                                        "lat": Double(location.coordinates.latitude).wrapped,
                                        "lng": Double(location.coordinates.longitude).wrapped,
                                        "address": location.address.wrapped,
                                        "external_source": location.identifier.flatMap(\.keys.first).wrapped,
                                        "external_id": location.identifier.flatMap(\.values.first).wrapped,
                                        (location.identifier.flatMap(\.keys.first) ?? "")+"_id": location.identifier.flatMap(\.values.first).wrapped]
                    body["geotag_enabled"] = 1
                    body["media_latitude"] = String(Double(location.coordinates.latitude)).wrapped
                    body["media_longitude"] = String(Double(location.coordinates.longitude)).wrapped
                    body["posting_latitude"] = body["media_latitude"]
                    body["posting_longitude"] = body["media_longitude"]
                }
                // Configure.
                return $0.appending(header: $1.header)
                    .signing(body: body.wrapped)
            }
    }

    /// Upload `image` to Instagram.
    /// - parameters:
    ///     - image: A `Data` representation of an image.
    ///     - size: A `CGSize` holding `width` and `height` of the original image.
    ///     - caption: An optional `String` holding the post's caption.
    ///     - users: An optional collection of `UserTag`s. Defaults to `nil`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload(image data: Data,
                       size: CGSize,
                       captioned caption: String?,
                       at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> {
        return upload(image: data, size: size, captioned: caption, tagging: [], at: location)
    }
}

public extension Endpoint.Media.Stories {
    /// The base endpoint.
    private static let base = Endpoint.version1.media.appendingDefaultHeader()

    /// All available stories for user matching `identifiers`.
    /// - parameters identifiers: A `Collection` of `String`s holding reference to valud user identifiers.
    static func by<C: Collection>(_ identifiers: C) -> Endpoint.Disposable<Wrapper> where C.Element == String {
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

    #if canImport(UIKit)
    /// Upload `image` to Instagram as a story.
    /// - parameters:
    ///     - image: A `UIImage` representation of an image.
    ///     - stickers: A sequence of `Stickers`.
    internal static func upload<S: Sequence>(image: UIImage, stickers: S) -> Endpoint.Disposable<Media.Unit> where S.Element == Sticker {
        guard let data = image.jpegData(compressionQuality: 1) else { fatalError("Invalid `UIImage`.") }
        return upload(image: data, size: image.size, stickers: stickers)
    }

    /// Upload `image` to Instagram as a story.
    /// - parameter image: A `UIImage` representation of an image.
    static func upload(image: UIImage) -> Endpoint.Disposable<Media.Unit> {
        guard let data = image.jpegData(compressionQuality: 1) else { fatalError("Invalid `UIImage`.") }
        return upload(image: data, size: image.size)
    }
    #endif

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// Upload `image` to Instagram as a story.
    /// - parameters:
    ///     - image: A `NSImage` representation of an image.
    ///     - stickers: A sequence of `Stickers`.
    internal static func upload<S: Sequence>(image: NSImage, stickers: S) -> Endpoint.Disposable<Media.Unit> where S.Element == Sticker {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
            let data = NSBitmapImageRep(cgImage: cgImage).representation(using: .jpeg, properties: [:]) else {
                fatalError("Invalid `UIImage`.")
        }
        return upload(image: data, size: image.size, stickers: stickers)
    }

    /// Upload `image` to Instagram as a story.
    /// - parameter image: A `NSImage` representation of an image.
    static func upload(image: NSImage) -> Endpoint.Disposable<Media.Unit> {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
            let data = NSBitmapImageRep(cgImage: cgImage).representation(using: .jpeg, properties: [:]) else {
                fatalError("Invalid `UIImage`.")
        }
        return upload(image: data, size: image.size)
    }
    #endif

    /// Upload `image` to Instagram as a story.
    /// - parameters:
    ///     - image: A `Data` representation of an image.
    ///     - size: A `CGSize` holding `width` and `height` of the original image.
    ///     - stickers: A sequence of `Stickers`.
    internal static func upload<S: Sequence>(image data: Data,
                                             size: CGSize,
                                             stickers: S) -> Endpoint.Disposable<Media.Unit> where S.Element == Sticker {
        /// Prepare upload parameters.
        let now = Date()
        let identifier = String(Int(now.timeIntervalSince1970*1_000))
        let name = identifier+"_0_\(Int64.random(in: 1_000_000_000...9_999_999_999))"
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
            "X-Instagram-Rupload-Params": try? rupload.wrapped.jsonRepresentation(),
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
            .prepare(process: Media.Unit.self)
            .switch {
                // Configure the picture you've just updated.
                guard let response = try? $0.get(), response.error == nil else { return nil }
                // The actual configuration will be performed by the preprocessor on `unlocking`.
                return base.appending(path: "configure_to_story/")
            }
            .locking(Secret.self) {
                // Unlock when dealing with the first call.
                guard $0.request()?.url?.absoluteString.contains("configure") ?? false else {
                    return $0.appending(header: $1.header)
                        .appending(header: "IG-U-DS-User-ID", with: $1.id)
                }

                // Prepare the configuration request.
                // Prepare edits and extras.
                let edits: Wrapper = [
                    "crop_original_size": [Int(size.width), Int(size.height)].wrapped,
                    "crop_center": [0.0, -0.0],
                    "crop_zoom": 1.0
                ]
                let extras: Wrapper = [
                    "source_width": Int(size.width).wrapped,
                    "source_height": Int(size.height).wrapped
                ]
                // Prepare the body.
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy:MM:dd' 'HH:mm:ss"
                let formattedNow = formatter.string(from: now)
                var body: [String: Wrapper] = [
                    "upload_id": identifier.wrapped,
                    "width": Int(size.width).wrapped,
                    "height": Int(size.height).wrapped,
                    "timezone_offset": "43200",
                    "date_time_original": formattedNow.wrapped,
                    "date_time_digitalized": formattedNow.wrapped,
                    "source_type": "3",
                    "configure_mode": "1",
                    "media_folder": "Instagram",
                    "edits": edits,
                    "extra": extras,
                    "camera_model": $1.device.model.wrapped,
                    "scene_capture_type": "standard",
                    "creation_logger_session_id": $1.session!.value.wrapped,
                    "software": "1",
                    "camera_make": $1.device.brand.wrapped,
                    "device": (try? $1.device.payload.wrapped.jsonRepresentation()).wrapped,
                    "_csrftoken": $1.crossSiteRequestForgery.value.wrapped,
                    "user_id": identifier.wrapped,
                    "_uid": $1.id.wrapped,
                    "device_id": $1.device.deviceIdentifier.wrapped,
                    "_uuid": $1.device.deviceGUID.uuidString.wrapped
                ]
                /*if let stickersDictionary = [Sticker].request(Array(stickers))?.dictionary(), !stickersDictionary.isEmpty {
                    body.merge(stickersDictionary) { lhs, _ in lhs }
                }*/
                // Configure.
                return $0.appending(header: $1.header)
                    .signing(body: body.wrapped)
            }
    }

    /// Upload `image` to Instagram as a story.
    /// - parameters:
    ///     - image: A `Data` representation of an image.
    ///     - size: A `CGSize` holding `width` and `height` of the original image.
    static func upload(image data: Data, size: CGSize) -> Endpoint.Disposable<Media.Unit> {
        return upload(image: data, size: size, stickers: [])
    }
}
