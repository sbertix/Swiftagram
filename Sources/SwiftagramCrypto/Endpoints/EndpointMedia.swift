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
#if canImport(AVKit)
import AVKit
#endif

import ComposableRequest
import Swiftagram

public extension Endpoint.Media {
    /// The base endpoint.
    private static let base = Endpoint.version1.media.appendingDefaultHeader()

    /// Delete the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    static func delete(_ identifier: String) -> Endpoint.Disposable<Status> {
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

// MARK: - Posts
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

    // MARK: - Image upload
    #if canImport(UIKit) || (canImport(AppKit) && !targetEnvironment(macCatalyst))
    /// Upload `image` to instagram.
    /// - parameters:
    ///     - image: An `Agnostic.Image` (either `UIImage` or `NSImage`).
    ///     - caption: An optional `String`.
    ///     - users: A collection of `UserTag`s.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload<U: Collection>(image: Agnostic.Image,
                                      captioned caption: String?,
                                      tagging users: U,
                                      at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> where U.Element == UserTag {
        guard let data = image.jpegRepresentation() else { fatalError("Invalid `jpeg` representation.") }
        return upload(image: data, size: image.size, captioned: caption, tagging: users, at: location)
    }

    /// Upload `image` to instagram.
    /// - parameters:
    ///     - image: An `Agnostic.Image` (either `UIImage` or `NSImage`).
    ///     - caption: An optional `String`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload(image: Agnostic.Image,
                       captioned caption: String?,
                       at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> {
        return upload(image: image, captioned: caption, tagging: [], at: location)
    }

    /// Upload `image` to instagram.
    /// - parameters:
    ///     - data: Some `Data` holding reference to a `jpeg` representation.
    ///     - size: A valid `CGSize`.
    ///     - caption: An optional `String`.
    ///     - users: A collection of `UserTag`s.
    ///     - location: An optional `Location`. Defaults to `nil`.
    internal static func upload<U: Collection>(image data: Data,
                                               size: CGSize,
                                               captioned caption: String?,
                                               tagging users: U,
                                               at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> where U.Element == UserTag {
        // Prepare the uploader.
        let uploader = Endpoint.Media.upload(image: data)
        return uploader.fetcher
            .switch {
                // Configure the picture you've just updated.
                guard let response = try? $0.get(), response.error == nil else { return nil }
                // The actual configuration will be performed by the preprocessor on `unlocking`.
                return base.appending(path: "configure/")
            }
            .locking(Secret.self) {
                // Unlock when dealing with the first call.
                guard $0.request()?.url?.absoluteString.contains("configure") ?? false else {
                    return $0.appending(header: $1.header).appending(header: "IG-U-DS-User-ID", with: $1.id)
                }

                // Prepare the configuration request.
                // Prepare body.
                var body: [String: Wrapper] = [
                    "caption": caption.wrapped,
                    "media_folder": "Instagram",
                    "source_type": "4",
                    "upload_id": uploader.identifier.wrapped,
                    "device": $1.device.payload.wrapped,
                    "edits": ["crop_original_size": [size.width.wrapped, size.height.wrapped],
                              "crop_center": [-0.0, 0.0],
                              "crop_zoom": 1.0],
                    "extra": ["source_width": size.width.wrapped,
                              "source_height": size.height.wrapped],
                    "_csrftoken": $1.crossSiteRequestForgery.value.wrapped,
                    "user_id": uploader.identifier.wrapped,
                    "_uid": $1.id.wrapped,
                    "device_id": $1.device.deviceIdentifier.wrapped,
                    "_uuid": $1.device.deviceGUID.uuidString.wrapped
                ]
                // Add user tags.
                let users = users.compactMap({ $0.wrapper().snakeCased().optional() })
                if !users.isEmpty,
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
                    body["exif_latitude"] = "0.0"
                    body["exif_longitude"] = "0.0"
                }
                // Configure.
                return $0.appending(header: $1.header).signing(body: body.wrapped)
            }
    }

    /// Upload `image` to instagram.
    /// - parameters:
    ///     - data: Some `Data` holding reference to an image.
    ///     - caption: An optional `String`.
    ///     - users: A collection of `UserTag`s.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload<U: Collection>(image data: Data,
                                      captioned caption: String?,
                                      tagging users: U,
                                      at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> where U.Element == UserTag {
        guard let image = Agnostic.Image(data: data) else { fatalError("Invalid `data`.") }
        return upload(image: image, captioned: caption, tagging: users, at: location)
    }

    /// Upload `image` to instagram.
    /// - parameters:
    ///     - data: Some `Data` holding reference to an image.
    ///     - caption: An optional `String`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload(image data: Data,
                       captioned caption: String?,
                       at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> {
        return upload(image: data, captioned: caption, tagging: [], at: location)
    }

    #if canImport(AVKit)
    // MARK: - Video upload
    /// Upload `video` to instagram.
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - image: An `Agnostic.Image` (either `UIImage` or `NSImage`) used as preview image.
    ///     - caption: An optional `String`.
    ///     - users: A collection of `UserTag`s.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload<U: Collection>(video url: URL,
                                      preview image: Agnostic.Image,
                                      captioned caption: String?,
                                      tagging users: U,
                                      at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> where U.Element == UserTag {
        guard let data = image.jpegRepresentation() else { fatalError("Invalid `jpeg` representation.") }
        return upload(video: url, preview: data, size: image.size, captioned: caption, tagging: users, at: location)
    }

    /// Upload `video` to instagram.
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - image: An `Agnostic.Image` (either `UIImage` or `NSImage`) used as preview image.
    ///     - caption: An optional `String`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload(video url: URL,
                       preview image: Agnostic.Image,
                       captioned caption: String?,
                       at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> {
        return upload(video: url, preview: image, captioned: caption, tagging: [], at: location)
    }

    /// Upload `video` to instagram.
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - data: Some `Data` holding reference to a `jpeg` representation, to be used as preview image.
    ///     - size: A valid `CGSize`.
    ///     - caption: An optional `String`.
    ///     - users: A collection of `UserTag`s.
    ///     - location: An optional `Location`. Defaults to `nil`.
    internal static func upload<U: Collection>(video url: URL,
                                               preview data: Data,
                                               size: CGSize,
                                               captioned caption: String?,
                                               tagging users: U,
                                               at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> where U.Element == UserTag {
        // Prepare the uploader.
        let uploader = Endpoint.Media.upload(video: url, preview: data, previewSize: size)
        guard uploader.duration < 60 else { fatalError("The video must be less than 1 minute long.") }
        return uploader.fetcher
            .switch {
                // Finish the upload.
                guard let response = try? $0.get(), response.error == nil else { return nil }
                // The actual configuration will be performed by the preprocessor on `unlocking`.
                return base
                    .appending(path: "configure/")
                    .appending(query: ["video": "1"])
            }
            .locking(Secret.self) {
                // Unlock when dealing with the first call.
                guard let path = $0.request()?.url?.absoluteString else { fatalError("Invalid url.") }
                // Configure.
                if path.contains("upload_finish") {
                    return $0.appending(header: $1.header)
                        .appending(query: ["video": "1"])
                        .signing(body: ["device": $1.device.payload.wrapped,
                                        "timezone_offset": "43200",
                                        "_csrftoken": $1.crossSiteRequestForgery.value.wrapped,
                                        "user_id": uploader.identifier.wrapped,
                                        "_uid": $1.id.wrapped,
                                        "device_id": $1.device.deviceIdentifier.wrapped,
                                        "_uuid": $1.device.deviceGUID.uuidString.wrapped,
                                        "upload_id": uploader.identifier.wrapped,
                                        "clips": [["length": uploader.duration.wrapped, "source_type": "3"]],
                                        "source_type": "4",
                                        "length": Int(uploader.duration).wrapped,
                                        "poster_frame_index": 0,
                                        "audio_muted": false].wrapped)
                } else if path.contains("configure") {
                    // Prepare the configuration request.
                    // Prepare body.
                    var body: [String: Wrapper] = [
                        //"caption": caption.wrapped,
                        "media_folder": "Instagram",
                        "source_type": "4",
                        "upload_id": uploader.identifier.wrapped,
                        "device": $1.device.payload.wrapped,
                        "length": uploader.duration.wrapped,
                        "width": uploader.size.width.wrapped,
                        "height": uploader.size.height.wrapped,
                        "clips": [["length": uploader.duration.wrapped, "source_type": "4"]],
                        "_csrftoken": $1.crossSiteRequestForgery.value.wrapped,
                        "user_id": uploader.identifier.wrapped,
                        "_uid": $1.id.wrapped,
                        "device_id": $1.device.deviceIdentifier.wrapped,
                        "_uuid": $1.device.deviceGUID.uuidString.wrapped,
                        "filter_type": "0",
                        "poster_frame_index": 0,
                        "audio_muted": false
                    ]
                    // Add user tags.
                    let users = users.compactMap({ $0.wrapper().snakeCased().optional() })
                    if !users.isEmpty,
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
                                            (location.identifier.flatMap(\.keys.first) ?? "")+"_id": location.identifier
                                                .flatMap(\.values.first)
                                                .wrapped]
                        body["geotag_enabled"] = 1
                        body["media_latitude"] = String(Double(location.coordinates.latitude)).wrapped
                        body["media_longitude"] = String(Double(location.coordinates.longitude)).wrapped
                        body["posting_latitude"] = body["media_latitude"]
                        body["posting_longitude"] = body["media_longitude"]
                        body["exif_latitude"] = "0.0"
                        body["exif_longitude"] = "0.0"
                    }
                    // Configure.
                    return $0.appending(header: $1.header)
                        .signing(body: body.wrapped)
                } else {
                    return $0.appending(header: $1.header)
                }
            }
    }

    /// Upload `video` to instagram.
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - data: Some `Data` holding reference to an image to be used as preview image.
    ///     - caption: An optional `String`.
    ///     - users: A collection of `UserTag`s.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload<U: Collection>(video url: URL,
                                      preview data: Data,
                                      captioned caption: String?,
                                      tagging users: U,
                                      at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> where U.Element == UserTag {
        guard let image = Agnostic.Image(data: data) else { fatalError("Invalid `data`.") }
        return upload(video: url, preview: image, captioned: caption, tagging: users, at: location)
    }

    /// Upload `video` to instagram.
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - data: Some `Data` holding reference to an image to be used as preview image.
    ///     - caption: An optional `String`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    static func upload(video url: URL,
                       preview data: Data,
                       captioned caption: String?,
                       at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> {
        return upload(video: url, preview: data, captioned: caption, tagging: [], at: location)
    }
    #endif
    #endif
}

// MARK: - Stories
public extension Endpoint.Media.Stories {
    /// The base endpoint.
    private static let base = Endpoint.version1.media.appendingDefaultHeader()

    // MARK: - Image upload
    #if canImport(UIKit) || (canImport(AppKit) && !targetEnvironment(macCatalyst))
    /// Upload story `image` to instagram.
    /// - parameters:
    ///     - image: An `Agnostic.Image` (either `UIImage` or `NSImage`).
    ///     - stickers: A sequence of `Sticker`s.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    static func upload<S: Sequence>(image: Agnostic.Image,
                                    stickers: S,
                                    isCloseFriendsOnly: Bool = false) -> Endpoint.Disposable<Media.Unit> where S.Element == Sticker {
        guard let data = image.jpegRepresentation() else { fatalError("Invalid `jpeg` representation.") }
        return upload(image: data, size: image.size, stickers: stickers, isCloseFriendsOnly: isCloseFriendsOnly)
    }

    /// Upload story `image` to instagram.
    /// - parameters:
    ///     - image: An `Agnostic.Image` (either `UIImage` or `NSImage`).
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    static func upload(image: Agnostic.Image, isCloseFriendsOnly: Bool = false) -> Endpoint.Disposable<Media.Unit> {
        return upload(image: image, stickers: [], isCloseFriendsOnly: isCloseFriendsOnly)
    }

    /// Upload story `image` to instagram.
    /// - parameters:
    ///     - data: Some `Data` holding reference to a `jpeg` representation.
    ///     - size: A valid `CGSize`.
    ///     - stickers: A sequence of `Sticker`s.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    internal static func upload<S: Sequence>(image data: Data,
                                             size: CGSize,
                                             stickers: S,
                                             isCloseFriendsOnly: Bool = false) -> Endpoint.Disposable<Media.Unit> where S.Element == Sticker {
        // Prepare the uploader.
        let uploader = Endpoint.Media.upload(image: data)
        return uploader.fetcher
            .switch {
                // Configure the picture you've just updated.
                guard let response = try? $0.get(), response.error == nil else { return nil }
                // The actual configuration will be performed by the preprocessor on `unlocking`.
                return base.appending(path: "configure_to_story/").appending(query: ["video": "1"])
            }
            .locking(Secret.self) {
                // Unlock when dealing with the first call.
                guard $0.request()?.url?.absoluteString.contains("configure") ?? false else {
                    return $0.appending(header: $1.header).appending(header: "IG-U-DS-User-ID", with: $1.id)
                }

                // Prepare the configuration request.
                let seconds = Int(uploader.date.timeIntervalSince1970)
                // Prepare the body.
                var body: [String: Wrapper] = [
                    "source_type": "4",
                    "upload_id": uploader.identifier.wrapped,
                    "story_media_creation_date": String(seconds-Int.random(in: 11...20)).wrapped,
                    "client_shared_at": String(seconds-Int.random(in: 3...10)).wrapped,
                    "client_timestamp": String(seconds).wrapped,
                    "configure_mode": 1,
                    "device": $1.device.payload.wrapped,
                    "edits": ["crop_original_size": [size.width.wrapped, size.height.wrapped],
                              "crop_center": [-0.0, 0.0],
                              "crop_zoom": 1.0],
                    "extra": ["source_width": size.width.wrapped,
                              "source_height": size.height.wrapped],
                    "_csrftoken": $1.crossSiteRequestForgery.value.wrapped,
                    "user_id": uploader.identifier.wrapped,
                    "_uid": $1.id.wrapped,
                    "device_id": $1.device.deviceIdentifier.wrapped,
                    "_uuid": $1.device.deviceGUID.uuidString.wrapped
                ]
                // Add to close friends only.
                if isCloseFriendsOnly { body["audience"] = "besties" }
                // Update stickers.
                body.merge(stickers.request()) { lhs, _ in lhs }
                // Configure.
                return $0.appending(header: $1.header).signing(body: body.wrapped)
            }
    }

    /// Upload story `image` to instagram.
    /// - parameters:
    ///     - data: Some `Data` holding reference to an image.
    ///     - stickers: A sequence of `Sticker`s.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    static func upload<S: Collection>(image data: Data,
                                      stickers: S,
                                      isCloseFriendsOnly: Bool = false) -> Endpoint.Disposable<Media.Unit> where S.Element == Sticker {
        guard let image = Agnostic.Image(data: data) else { fatalError("Invalid `data`.") }
        return upload(image: image, stickers: stickers, isCloseFriendsOnly: isCloseFriendsOnly)
    }

    /// Upload story `image` to instagram.
    /// - parameters:
    ///     - data: Some `Data` holding reference to an image.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    static func upload(image data: Data, isCloseFriendsOnly: Bool = false) -> Endpoint.Disposable<Media.Unit> {
        return upload(image: data, stickers: [], isCloseFriendsOnly: isCloseFriendsOnly)
    }

    #if canImport(AVKit)
    // MARK: - Video upload
    /// Upload story `video` to instagram.
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - image: An optional `Agnostic.Image` to be used as preview. Defaults to `nil`, meaning a full black preview will be used.
    ///     - stickers: A sequence of `Sticker`s.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    static func upload<S: Sequence>(video url: URL,
                                    preview image: Agnostic.Image? = nil,
                                    stickers: S,
                                    isCloseFriendsOnly: Bool = false) -> Endpoint.Disposable<Media.Unit> where S.Element == Sticker {
        return upload(video: url,
                      preview: image?.jpegRepresentation(),
                      size: image?.size ?? .zero,
                      stickers: stickers,
                      isCloseFriendsOnly: isCloseFriendsOnly)
    }

    /// Upload story `video` to instagram.
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - image: An `Agnostic.Image` to be used as preview. Defaults to `nil`, meaning a full black preview will be used.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    static func upload(video url: URL, preview image: Agnostic.Image? = nil, isCloseFriendsOnly: Bool = false) -> Endpoint.Disposable<Media.Unit> {
        return upload(video: url, preview: image, stickers: [], isCloseFriendsOnly: isCloseFriendsOnly)
    }

    /// Upload story `video` to instagram.
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - data: Some `Data` holding reference to a `jpeg` representation to be used as preview. `nil` means a full black preview will be used.
    ///     - size: A valid `CGSize`.
    ///     - stickers: A sequence of `Sticker`s.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    internal static func upload<S: Sequence>(video url: URL,
                                             preview data: Data?,
                                             size: CGSize,
                                             stickers: S,
                                             isCloseFriendsOnly: Bool = false) -> Endpoint.Disposable<Media.Unit> where S.Element == Sticker {
        // Prepare the uploader.
        let uploader = Endpoint.Media.upload(video: url,
                                             preview: data,
                                             previewSize: size,
                                             isForAlbum: true)
        guard uploader.duration < 15 else { fatalError("The video must be less than 15 seconds long.") }
        return uploader.fetcher
            .switch {
                // Configure the picture you've just updated.
                guard let response = try? $0.get(), response.error == nil else { return nil }
                // The actual configuration will be performed by the preprocessor on `unlocking`.
                return base.appending(path: "configure_to_story/")
            }
            .locking(Secret.self) {
                // Unlock when dealing with the first call.
                guard let path = $0.request()?.url?.absoluteString else { fatalError("Invalid url.") }
                // Add
                // Configure.
                if path.contains("upload_finish") {
                    return $0.appending(header: $1.header)
                        .appending(query: ["video": "1"])
                        .signing(body: ["device": $1.device.payload.wrapped,
                                        "timezone_offset": "43200",
                                        "_csrftoken": $1.crossSiteRequestForgery.value.wrapped,
                                        "user_id": uploader.identifier.wrapped,
                                        "_uid": $1.id.wrapped,
                                        "device_id": $1.device.deviceIdentifier.wrapped,
                                        "_uuid": $1.device.deviceGUID.uuidString.wrapped,
                                        "upload_id": uploader.identifier.wrapped,
                                        "clips": [["length": uploader.duration.wrapped, "source_type": "3"]],
                                        "source_type": "3",
                                        "length": Int(uploader.duration).wrapped,
                                        "poster_frame_index": 0,
                                        "audio_muted": false].wrapped)
                } else if path.contains("configure") {
                    // Prepare the configuration request.
                    let seconds = Int(uploader.date.timeIntervalSince1970)
                    // Prepare the body.
                    var body: [String: Wrapper] = [
                        "supported_capabilities_new": (try? SupportedCapabilities
                                                        .default
                                                        .map { ["name": $0.key, "value": $0.value] }
                                                        .wrapped
                                                        .jsonRepresentation()).wrapped,
                        "timezone_offset": "43200",
                        "source_type": "3",
                        "upload_id": uploader.identifier.wrapped,
                        "story_media_creation_date": String(seconds-Int.random(in: 11...20)).wrapped,
                        "client_shared_at": String(seconds-Int.random(in: 3...10)).wrapped,
                        "client_timestamp": String(seconds).wrapped,
                        "configure_mode": 1,
                        "device": $1.device.payload.wrapped,
                        "clips": [["length": uploader.duration.wrapped, "source_type": "3"]],
                        "extra": ["source_width": uploader.size.width.wrapped,
                                  "source_height": uploader.size.height.wrapped],
                        "_csrftoken": $1.crossSiteRequestForgery.value.wrapped,
                        "user_id": uploader.identifier.wrapped,
                        "_uid": $1.id.wrapped,
                        "device_id": $1.device.deviceIdentifier.wrapped,
                        "_uuid": $1.device.deviceGUID.uuidString.wrapped,
                        "audio_muted": false,
                        "poster_frame_index": 0,
                        "video_result": ""
                    ]
                    // Add to close friends only.
                    if isCloseFriendsOnly { body["audience"] = "besties" }
                    // Update stickers.
                    body.merge(stickers.request()) { lhs, _ in lhs }
                    // Configure.
                    return $0.appending(header: $1.header)
                        .appending(query: ["video": "1"])
                        .signing(body: body.wrapped)
                } else {
                    return $0.appending(header: $1.header)
                }
            }
    }

    /// Upload story `video` to instagram.
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - data: Some `Data` holding reference to an image to be used as preview.
    ///     - stickers: A sequence of `Sticker`s.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    static func upload<S: Collection>(video url: URL,
                                      preview data: Data,
                                      stickers: S,
                                      isCloseFriendsOnly: Bool = false) -> Endpoint.Disposable<Media.Unit> where S.Element == Sticker {
        return upload(video: url, preview: Agnostic.Image(data: data), stickers: stickers, isCloseFriendsOnly: isCloseFriendsOnly)
    }

    /// Upload story `video` to instagram.
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - data: Some `Data` holding reference to an image to be used as preview.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    static func upload(video url: URL, preview data: Data, isCloseFriendsOnly: Bool = false) -> Endpoint.Disposable<Media.Unit> {
        return upload(video: url, preview: data, stickers: [], isCloseFriendsOnly: isCloseFriendsOnly)
    }
    #endif
    #endif
}
