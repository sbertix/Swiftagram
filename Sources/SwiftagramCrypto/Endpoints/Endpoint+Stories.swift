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

    #endif
}
