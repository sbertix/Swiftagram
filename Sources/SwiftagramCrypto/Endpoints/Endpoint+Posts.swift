//
//  Endpoint+Posts.swift
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

public extension Endpoint.Group.Posts {
    #if canImport(UIKit) || (canImport(AppKit) && !targetEnvironment(macCatalyst))

    /// Upload `image` to instagram.
    ///
    /// - parameters:
    ///     - image: An `Agnostic.Image` (either `UIImage` or `NSImage`).
    ///     - caption: An optional `String`.
    ///     - users: A collection of `UserTag`s.
    ///     - location: An optional `Location`. Defaults to `nil`.
    /// - note: **SwiftagramCrypto** only.
    func upload<U: Collection>(image: Agnostic.Image,
                               captioned caption: String?,
                               tagging users: U,
                               at location: Location? = nil) -> Endpoint.Single<Media.Unit, Error>
    where U.Element == UserTag {
        guard let data = image.jpegRepresentation() else { fatalError("Invalid `jpeg` representation.") }
        return upload(image: data, size: image.size, captioned: caption, tagging: users, at: location)
    }

    /// Upload `image` to instagram.
    ///
    /// - parameters:
    ///     - image: An `Agnostic.Image` (either `UIImage` or `NSImage`).
    ///     - caption: An optional `String`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    /// - note: **SwiftagramCrypto** only.
    func upload(image: Agnostic.Image,
                captioned caption: String?,
                at location: Location? = nil) -> Endpoint.Single<Media.Unit, Error> {
        upload(image: image, captioned: caption, tagging: [], at: location)
    }

    // swiftlint:disable function_body_length
    /// Upload `image` to instagram.
    ///
    /// - parameters:
    ///     - data: Some `Data` holding reference to a `jpeg` representation.
    ///     - size: A valid `CGSize`.
    ///     - caption: An optional `String`.
    ///     - users: A collection of `UserTag`s.
    ///     - location: An optional `Location`. Defaults to `nil`.
    /// - note: **SwiftagramCrypto** only.
    internal func upload<U: Collection>(image data: Data,
                                        size: CGSize,
                                        captioned caption: String?,
                                        tagging users: U,
                                        at location: Location? = nil) -> Endpoint.Single<Media.Unit, Error>
    where U.Element == UserTag {
        .init { secret, session in
            Deferred { () -> AnyPublisher<Media.Unit, Error> in
                let upload = Endpoint.uploader.upload(image: data)
                // Compose the future.
                return upload.generator((secret, session))
                    .flatMap { output -> AnyPublisher<Media.Unit, Error> in
                        guard output.error == nil else {
                            return Just(output).setFailureType(to: Error.self).eraseToAnyPublisher()
                        }
                        // Configure the picture.
                        // Prepare the body.
                        var body: [String: Wrapper] = [
                            "caption": caption.wrapped,
                            "media_folder": "Instagram",
                            "source_type": "4",
                            "upload_id": upload.identifier.wrapped,
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
                        // Add user tags.
                        let users = users.compactMap { $0.wrapper().snakeCased().optional() }
                        if !users.isEmpty, let description = try? ["in": users.wrapped].wrapped.jsonRepresentation() {
                            body["usertags"] = description.wrapped
                        }
                        // Add location.
                        if let location = location {
                            body["location"] = ["name": location.name.wrapped,
                                                "lat": (location.coordinates?.latitude).flatMap(Double.init).wrapped,
                                                "lng": (location.coordinates?.longitude).flatMap(Double.init).wrapped,
                                                "address": location.address.wrapped,
                                                "external_source": location.identifier.flatMap(\.keys.first).wrapped,
                                                "external_id": location.identifier.flatMap(\.values.first).wrapped,
                                                (location.identifier.flatMap(\.keys.first) ?? "") + "_id":
                                                    location.identifier.flatMap(\.values.first).wrapped]
                            body["geotag_enabled"] = 1
                            body["media_latitude"] = (location.coordinates?.latitude)
                                .flatMap { String(Double($0)) }.wrapped
                            body["media_longitude"] = (location.coordinates?.longitude)
                                .flatMap { String(Double($0)) }.wrapped
                            body["posting_latitude"] = body["media_latitude"]
                            body["posting_longitude"] = body["media_longitude"]
                            body["exif_latitude"] = "0.0"
                            body["exif_longitude"] = "0.0"
                        }
                        // Return the new future.
                        return Request.media
                            .path(appending: "configure/")
                            .header(appending: secret.header)
                            .signing(body: body.wrapped)
                            .publish(with: session)
                            .map(\.data)
                            .wrap()
                            .map(Media.Unit.init)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
    }
    // swiftlint:enable function_body_length

    /// Upload `image` to instagram.
    ///
    /// - parameters:
    ///     - data: Some `Data` holding reference to an image.
    ///     - caption: An optional `String`.
    ///     - users: A collection of `UserTag`s.
    ///     - location: An optional `Location`. Defaults to `nil`.
    /// - note: **SwiftagramCrypto** only.
    func upload<U: Collection>(image data: Data,
                               captioned caption: String?,
                               tagging users: U,
                               at location: Location? = nil) -> Endpoint.Single<Media.Unit, Error>
    where U.Element == UserTag {
        guard let image = Agnostic.Image(data: data) else { fatalError("Invalid `data`.") }
        return upload(image: image, captioned: caption, tagging: users, at: location)
    }

    /// Upload `image` to instagram.
    ///
    /// - parameters:
    ///     - data: Some `Data` holding reference to an image.
    ///     - caption: An optional `String`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    /// - note: **SwiftagramCrypto** only.
    func upload(image data: Data,
                captioned caption: String?,
                at location: Location? = nil) -> Endpoint.Single<Media.Unit, Error> {
        upload(image: data, captioned: caption, tagging: [], at: location)
    }

    #if canImport(AVFoundation)

    /// Upload `video` to instagram.
    ///
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - image: An `Agnostic.Image` (either `UIImage` or `NSImage`) used as preview image.
    ///     - caption: An optional `String`.
    ///     - users: A collection of `UserTag`s.
    ///     - location: An optional `Location`. Defaults to `nil`.
    /// - note: **SwiftagramCrypto** only.
    @available(watchOS 6, *)
    func upload<U: Collection>(video url: URL,
                               preview image: Agnostic.Image,
                               captioned caption: String?,
                               tagging users: U,
                               at location: Location? = nil) -> Endpoint.Single<Media.Unit, Error>
    where U.Element == UserTag {
        guard let data = image.jpegRepresentation() else { fatalError("Invalid `jpeg` representation.") }
        return upload(video: url,
                      preview: data,
                      size: image.size,
                      captioned: caption,
                      tagging: users,
                      at: location)
    }

    /// Upload `video` to instagram.
    ///
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - image: An `Agnostic.Image` (either `UIImage` or `NSImage`) used as preview image.
    ///     - caption: An optional `String`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    /// - note: **SwiftagramCrypto** only.
    @available(watchOS 6, *)
    func upload(video url: URL,
                preview image: Agnostic.Image,
                captioned caption: String?,
                at location: Location? = nil) -> Endpoint.Single<Media.Unit, Error> {
        upload(video: url, preview: image, captioned: caption, tagging: [], at: location)
    }

    // swiftlint:disable function_body_length
    /// Upload `video` to instagram.
    ///
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - data: Some `Data` holding reference to a `jpeg` representation, to be used as preview image.
    ///     - size: A valid `CGSize`.
    ///     - caption: An optional `String`.
    ///     - users: A collection of `UserTag`s.
    ///     - location: An optional `Location`. Defaults to `nil`.
    /// - note: **SwiftagramCrypto** only.
    @available(watchOS 6, *)
    internal func upload<U: Collection>(video url: URL,
                                        preview data: Data,
                                        size: CGSize,
                                        captioned caption: String?,
                                        tagging users: U,
                                        at location: Location? = nil) -> Endpoint.Single<Media.Unit, Error>
    where U.Element == UserTag {
        .init { secret, session in
            Deferred { () -> AnyPublisher<Media.Unit, Error> in
                let upload = Endpoint.uploader.upload(video: url,
                                                      preview: data,
                                                      previewSize: size,
                                                      sourceType: "4")
                guard upload.duration < 60 else {
                    return Fail(error: Endpoint.Group.Media.Error.videoTooLong(seconds: upload.duration))
                        .eraseToAnyPublisher()
                }
                // Compose the future.
                return upload.generator((secret, session))
                    .flatMap { output -> AnyPublisher<Media.Unit, Error> in
                        guard output.error == nil else {
                            return Just(output).setFailureType(to: Error.self).eraseToAnyPublisher()
                        }
                        // Configure the video.
                        var body: [String: Wrapper] = [
                            "caption": caption.wrapped,
                            "media_folder": "Instagram",
                            "source_type": "4",
                            "upload_id": upload.identifier.wrapped,
                            "length": upload.duration.wrapped,
                            "width": upload.size.width.wrapped,
                            "height": upload.size.height.wrapped,
                            "clips": [["length": upload.duration.wrapped, "source_type": "4"]],
                            "_csrftoken": secret["csrftoken"].wrapped,
                            "user_id": upload.identifier.wrapped,
                            "_uid": secret.identifier.wrapped,
                            "device_id": secret.client.device.instagramIdentifier.wrapped,
                            "_uuid": secret.client.device.identifier.uuidString.wrapped,
                            "filter_type": "0",
                            "poster_frame_index": 0,
                            "audio_muted": false
                        ]
                        // Add user tags.
                        let users = users.compactMap { $0.wrapper().snakeCased().optional() }
                        if !users.isEmpty,
                           let description = try? ["in": users.wrapped].wrapped.jsonRepresentation() {
                            body["usertags"] = description.wrapped
                        }
                        // Add location.
                        if let location = location {
                            body["location"] = ["name": location.name.wrapped,
                                                "lat": (location.coordinates?.latitude)
                                                    .flatMap(Double.init)
                                                    .wrapped,
                                                "lng": (location.coordinates?.longitude)
                                                    .flatMap(Double.init)
                                                    .wrapped,
                                                "address": location.address.wrapped,
                                                "external_source": location.identifier
                                                    .flatMap(\.keys.first)
                                                    .wrapped,
                                                "external_id": location.identifier
                                                    .flatMap(\.values.first)
                                                    .wrapped,
                                                (location.identifier
                                                    .flatMap(\.keys.first) ?? "") + "_id": location.identifier
                                                    .flatMap(\.values.first)
                                                    .wrapped]
                            body["geotag_enabled"] = 1
                            body["media_latitude"] = (location.coordinates?.latitude)
                                .flatMap { String(Double($0)) }
                                .wrapped
                            body["media_longitude"] = (location.coordinates?.longitude)
                                .flatMap { String(Double($0)) }
                                .wrapped
                            body["posting_latitude"] = body["media_latitude"]
                            body["posting_longitude"] = body["media_longitude"]
                            body["exif_latitude"] = "0.0"
                            body["exif_longitude"] = "0.0"
                        }
                        // Return the new future.
                        return Request.media
                            .path(appending: "configure/")
                            .query(appending: "1", forKey: "video")
                            .header(appending: secret.header)
                            .signing(body: body.wrapped)
                            .publish(with: session)
                            .map(\.data)
                            .wrap()
                            .map(Media.Unit.init)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
    }
    // swiftlint:enable function_body_length

    /// Upload `video` to instagram.
    ///
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - data: Some `Data` holding reference to an image to be used as preview image.
    ///     - caption: An optional `String`.
    ///     - users: A collection of `UserTag`s.
    ///     - location: An optional `Location`. Defaults to `nil`.
    /// - note: **SwiftagramCrypto** only.
    @available(watchOS 6, *)
    func upload<U: Collection>(video url: URL,
                               preview data: Data,
                               captioned caption: String?,
                               tagging users: U,
                               at location: Location? = nil) -> Endpoint.Single<Media.Unit, Error>
    where U.Element == UserTag {
        guard let image = Agnostic.Image(data: data) else {
            fatalError("Invalid `data`.")
        }
        return upload(video: url, preview: image, captioned: caption, tagging: users, at: location)
    }

    /// Upload `video` to instagram.
    ///
    /// - parameters:
    ///     - url: A local or remote `URL` to a valid `.mp4` `h264` encoded video.
    ///     - data: Some `Data` holding reference to an image to be used as preview image.
    ///     - caption: An optional `String`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    /// - note: **SwiftagramCrypto** only.
    @available(watchOS 6, *)
    func upload(video url: URL,
                preview data: Data,
                captioned caption: String?,
                at location: Location? = nil) -> Endpoint.Single<Media.Unit, Error> {
        upload(video: url, preview: data, captioned: caption, tagging: [], at: location)
    }

    #endif
    #endif
}
