//
//  Endpoint+Stories.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 08/04/21.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

#if canImport(AVFoundation)
import AVFoundation
#endif

public extension Endpoint.Group.Stories {
    #if canImport(UIKit) || (canImport(AppKit) && !targetEnvironment(macCatalyst))

    /// Upload story `image` to instagram.
    ///
    /// - parameters:
    ///     - image: An `Agnostic.Image` (either `UIImage` or `NSImage`).
    ///     - stickers: A sequence of `Sticker`s.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    /// - note: **SwiftagramCrypto** only.
    func upload<S: Sequence>(image: Agnostic.Image,
                             stickers: S,
                             isCloseFriendsOnly: Bool = false) -> Endpoint.Single<Media.Unit>
    where S.Element == Sticker {
        guard let data = image.jpegRepresentation() else { fatalError("Invalid `jpeg` representation.") }
        return upload(image: data, size: image.size, stickers: stickers, isCloseFriendsOnly: isCloseFriendsOnly)
    }

    /// Upload story `image` to instagram.
    ///
    /// - parameters:
    ///     - image: An `Agnostic.Image` (either `UIImage` or `NSImage`).
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    /// - note: **SwiftagramCrypto** only.
    func upload(image: Agnostic.Image, isCloseFriendsOnly: Bool = false) -> Endpoint.Single<Media.Unit> {
        upload(image: image, stickers: [], isCloseFriendsOnly: isCloseFriendsOnly)
    }

    /// Upload story `image` to instagram.
    ///
    /// - parameters:
    ///     - data: Some `Data` holding reference to a `jpeg` representation.
    ///     - size: A valid `CGSize`.
    ///     - stickers: A sequence of `Sticker`s.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    /// - note: **SwiftagramCrypto** only.
    internal func upload<S: Sequence>(image data: Data,
                                      size: CGSize,
                                      stickers: S,
                                      isCloseFriendsOnly: Bool = false) -> Endpoint.Single<Media.Unit>
    where S.Element == Sticker {
        .init { secret, requester in
            let upload = Endpoint.uploader.upload(image: data)
            // Compose the future.
            return upload.generator((secret, requester))
                .switch { output -> R.Requested<Media.Unit> in
                    guard output.error == nil else {
                        return R.Once(output: output, with: requester).requested(by: requester)
                    }
                    // Configure the picture.
                    // Prepare the configuration request.
                    let seconds = Int(upload.date.timeIntervalSince1970)
                    // Prepare the body.
                    var body: [String: Wrapper] = [
                        "source_type": "4",
                        "upload_id": upload.identifier.wrapped,
                        "story_media_creation_date": String(seconds - Int.random(in: 11...20)).wrapped,
                        "client_shared_at": String(seconds - Int.random(in: 3...10)).wrapped,
                        "client_timestamp": String(seconds).wrapped,
                        "configure_mode": 1,
                        "edits": ["crop_original_size": [size.width.wrapped, size.height.wrapped],
                                  "crop_center": [-0.0, 0.0],
                                  "crop_zoom": 1.0],
                        "extra": ["source_width": size.width.wrapped,
                                  "source_height": size.height.wrapped],
                        "_csrftoken": secret["csrftoken"].wrapped,
                        "user_id": upload.identifier.wrapped,
                        "_uid": secret.identifier.wrapped,
                        "device_id": secret.client.device.instagramIdentifier.wrapped,
                        "_uuid": secret.client.device.identifier.uuidString.wrapped
                    ]
                    // Add to close friends only.
                    if isCloseFriendsOnly { body["audience"] = "besties" }
                    // Update stickers.
                    body.merge(stickers.request()) { lhs, _ in lhs }
                    // Return the new future.
                    return Request.media
                        .path(appending: "configure_to_story/")
                        .header(appending: secret.header)
                        .signing(body: body.wrapped)
                        .prepare(with: requester)
                        .map(\.data)
                        .decode()
                        .map(Media.Unit.init)
                        .requested(by: requester)
                }
                .requested(by: requester)
        }
    }

    /// Upload story `image` to instagram.
    ///
    /// - parameters:
    ///     - data: Some `Data` holding reference to an image.
    ///     - stickers: A sequence of `Sticker`s.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    /// - note: **SwiftagramCrypto** only.
    func upload<S: Collection>(image data: Data,
                               stickers: S,
                               isCloseFriendsOnly: Bool = false) -> Endpoint.Single<Media.Unit>
    where S.Element == Sticker {
        guard let image = Agnostic.Image(data: data) else { fatalError("Invalid `data`.") }
        return upload(image: image, stickers: stickers, isCloseFriendsOnly: isCloseFriendsOnly)
    }

    /// Upload story `image` to instagram.
    ///
    /// - parameters:
    ///     - data: Some `Data` holding reference to an image.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    /// - note: **SwiftagramCrypto** only.
    func upload(image data: Data, isCloseFriendsOnly: Bool = false) -> Endpoint.Single<Media.Unit> {
        upload(image: data, stickers: [], isCloseFriendsOnly: isCloseFriendsOnly)
    }

    #if canImport(AVFoundation)

    /// Upload story `video` to instagram.
    ///
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - image: An optional `Agnostic.Image` to be used as preview. Defaults to `nil`, meaning a full black preview will be used.
    ///     - stickers: A sequence of `Sticker`s.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    /// - note: **SwiftagramCrypto** only.
    @available(watchOS 6, *)
    func upload<S: Sequence>(video url: URL,
                             preview image: Agnostic.Image? = nil,
                             stickers: S,
                             isCloseFriendsOnly: Bool = false) -> Endpoint.Single<Media.Unit>
    where S.Element == Sticker {
        upload(video: url,
               preview: image?.jpegRepresentation(),
               size: image?.size ?? .zero,
               stickers: stickers,
               isCloseFriendsOnly: isCloseFriendsOnly)
    }

    /// Upload story `video` to instagram.
    ///
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - image: An `Agnostic.Image` to be used as preview. Defaults to `nil`, meaning a full black preview will be used.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    /// - note: **SwiftagramCrypto** only.
    @available(watchOS 6, *)
    func upload(video url: URL,
                preview image: Agnostic.Image? = nil,
                isCloseFriendsOnly: Bool = false) -> Endpoint.Single<Media.Unit> {
        upload(video: url, preview: image, stickers: [], isCloseFriendsOnly: isCloseFriendsOnly)
    }

    // swiftlint:disable function_body_length
    /// Upload story `video` to instagram.
    ///
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - data: Some `Data` holding reference to a `jpeg` representation to be used as preview. `nil` means a full black preview will be used.
    ///     - size: A valid `CGSize`.
    ///     - stickers: A sequence of `Sticker`s.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    /// - note: **SwiftagramCrypto** only.
    @available(watchOS 6, *)
    internal func upload<S: Sequence>(video url: URL,
                                      preview data: Data?,
                                      size: CGSize,
                                      stickers: S,
                                      isCloseFriendsOnly: Bool = false) -> Endpoint.Single<Media.Unit>
    where S.Element == Sticker {
        .init { secret, requester in
            let upload = Endpoint.uploader.upload(video: url,
                                                  preview: data,
                                                  previewSize: size,
                                                  sourceType: "3")
            guard upload.duration < 15 else {
                return R.Once(error: Endpoint.Group.Media.Error.videoTooLong(seconds: upload.duration),
                              with: requester)
                    .requested(by: requester)
            }
            // Compose the future.
            return upload.generator((secret, requester))
                .switch { output -> R.Requested<Media.Unit> in
                    guard output.error == nil else {
                        return R.Once(output: output, with: requester).requested(by: requester)
                    }
                    // Prepare the configuration request.
                    let seconds = Int(upload.date.timeIntervalSince1970)
                    // Prepare the body.
                    var body: [String: Wrapper] = [
                        "supported_capabilities_new": (try? SupportedCapabilities
                                                        .default
                                                        .map { ["name": $0.key, "value": $0.value] }
                                                        .wrapped
                                                        .jsonRepresentation()).wrapped,
                        "timezone_offset": "43200",
                        "source_type": "3",
                        "upload_id": upload.identifier.wrapped,
                        "story_media_creation_date": String(seconds - Int.random(in: 11...20)).wrapped,
                        "client_shared_at": String(seconds - Int.random(in: 3...10)).wrapped,
                        "client_timestamp": String(seconds).wrapped,
                        "configure_mode": 1,
                        "clips": [["length": upload.duration.wrapped, "source_type": "3"]],
                        "extra": ["source_width": upload.size.width.wrapped,
                                  "source_height": upload.size.height.wrapped],
                        "_csrftoken": secret["csrftoken"].wrapped,
                        "user_id": upload.identifier.wrapped,
                        "_uid": secret.identifier.wrapped,
                        "device_id": secret.client.device.instagramIdentifier.wrapped,
                        "_uuid": secret.client.device.identifier.uuidString.wrapped,
                        "audio_muted": false,
                        "poster_frame_index": 0,
                        "video_result": ""
                    ]
                    // Add to close friends only.
                    if isCloseFriendsOnly { body["audience"] = "besties" }
                    // Update stickers.
                    body.merge(stickers.request()) { lhs, _ in lhs }
                    // Return the new future.
                    return Request.media
                        .path(appending: "configure_to_story/")
                        .query(appending: "1", forKey: "video")
                        .header(appending: secret.header)
                        .signing(body: body.wrapped)
                        .prepare(with: requester)
                        .map(\.data)
                        .decode()
                        .map(Media.Unit.init)
                        .requested(by: requester)
                }
                .requested(by: requester)
        }
    }
    // swiftlint:enable function_body_length

    /// Upload story `video` to instagram.
    ///
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - data: Some `Data` holding reference to an image to be used as preview.
    ///     - stickers: A sequence of `Sticker`s.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    /// - note: **SwiftagramCrypto** only.
    @available(watchOS 6, *)
    func upload<S: Collection>(video url: URL,
                               preview data: Data,
                               stickers: S,
                               isCloseFriendsOnly: Bool = false) -> Endpoint.Single<Media.Unit>
    where S.Element == Sticker {
        upload(video: url,
               preview: Agnostic.Image(data: data),
               stickers: stickers,
               isCloseFriendsOnly: isCloseFriendsOnly)
    }

    /// Upload story `video` to instagram.
    ///
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - data: Some `Data` holding reference to an image to be used as preview.
    ///     - isCloseFriendsOnly: A valid `Bool`. Defaults to `false`.
    /// - note: **SwiftagramCrypto** only.
    @available(watchOS 6, *)
    func upload(video url: URL, preview data: Data, isCloseFriendsOnly: Bool = false) -> Endpoint.Single<Media.Unit> {
        upload(video: url, preview: data, stickers: [], isCloseFriendsOnly: isCloseFriendsOnly)
    }

    #endif
    #endif
}
