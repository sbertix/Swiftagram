//
//  Endpoint+Uploader.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 29/08/20.
//

import Foundation

#if canImport(AVFoundation)
import AVFoundation
#endif

#if canImport(CoreGraphics)
import CoreGraphics
#endif

extension Endpoint.Group {
    /// A `class` defining shared code for the upload process.
    final class Uploader { }
}

extension Endpoint {
    /// A wrapper for uploader code.
    static let uploader: Group.Uploader = .init()
}

extension Endpoint.Group.Uploader {
    /// Upload an image `data` with size `size`.
    ///
    /// - note: Make sure the `Future` generator is only ever called inside `Deferred`, otherwise it will fetch immediately.
    /// - parameters:
    ///     - data: Some `Data` representing a `jpeg` image.
    ///     - identifier: An optional `uploadId`. Defaults to `nil`.
    ///     - waterfallIdentifier: An optional `waterfallIdentifier`. Defaults to `nil`
    /// - returns: A `Media.Unit` `Disposable`, `identifier`, `name` and `date`.
    func upload(image data: Data,
                identifier: String? = nil,
                waterfallIdentifier: String? = nil) -> Upload.Image {
        /// Prepare upload parameters.
        let now = Date()
        let identifier = identifier ?? String(Int(now.timeIntervalSince1970 * 1_000))
        let name = identifier + "_0_\(Int64.random(in: 1_000_000_000...9_999_999_999))"
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
            "X_FB_PHOTO_WATERFALL_ID": waterfallIdentifier ?? UUID().uuidString,
            "X-Entity-Type": "image/jpeg",
            "Offset": "0",
            "X-Instagram-Rupload-Params": try? rupload.wrapped.jsonRepresentation(),
            "X-Entity-Name": name,
            "X-Entity-Length": length,
            "Content-Type": "application/octet-stream",
            "Content-Length": length,
            "Accept-Encoding": "gzip"
        ]
        // Return.
        return .init(identifier: identifier, name: name, date: now) { input in
            Request.api
                .path(appending: "rupload_igphoto")
                .path(appending: name)
                .appendingDefaultHeader()
                .header(appending: header)
                .header(appending: input.secret.header)
                .header(appending: input.secret.identifier, forKey: "IG-U-DS-User-ID")
                .body(data)
                .publish(with: input.session)
                .map(\.data)
                .wrap()
                .map(Media.Unit.init)
                .eraseToAnyPublisher()
        }
    }

    #if canImport(AVFoundation) && canImport(CoreGraphics)

    // swiftlint:disable function_body_length
    @available(watchOS 6, *)
    /// Upload video at `url`.
    /// - parameters:
    ///     - url: Some `url` to an `.mp4` video.
    ///     - data: Some `Data` representing a `jpeg` preview of the video.
    ///     - previewSize: A `CGSize` holding reference to the preview size.
    ///     - sourceType: A valid `String`.
    ///     - isForAlbum: A `Bool`.
    /// - returns: A `Media.Unit` `Disposable`, `identifier`, `name` and `date`.
    /// - warning: Remember to set `Secret` specific headers in the request.
    func upload(video url: URL,
                preview data: Data?,
                previewSize: CGSize,
                sourceType: String,
                isForAlbum: Bool = false) -> Upload.Video {
        // Prepare upload parameters.
        let video = AVAsset(url: url)
        let now = Date()
        let identifier = String(Int(now.timeIntervalSince1970 * 1_000))
        let waterfallIdentifier = UUID().uuidString
        let name = identifier + "_0_\(Int64.random(in: 1_000_000_000...9_999_999_999))"
        let track = video.tracks(withMediaType: .video).first
        let size = CGSize(width: track?.naturalSize.width ?? 0, height: track?.naturalSize.height ?? 0)
        guard let preview = data ?? Agnostic.Color.black.image(size: size)?.jpegRepresentation() else {
            fatalError("Invalid preview.")
        }
        precondition(size == previewSize || data == nil,
                     "Preview \(previewSize) and video \(size) must have the same width and height.")
        // Prepare the header.
        var rupload = [
            "retry_context": #"{"num_step_auto_retry":0,"num_reupload":0,"num_step_manual_retry":0}"#,
            "media_type": "2",
            "upload_id": identifier,
            "waterfall_id": waterfallIdentifier,
            "xsharing_user_ids": "[]",
            "image_compression": #"{"lib_name":"moz","lib_version":"3.1.m","quality":"80"}"#,
            "upload_media_durations_ms": "\(Int(video.duration.seconds * 1_000))",
            "upload_media_width": track.flatMap { $0.naturalSize.width }.flatMap(String.init),
            "upload_media_height": track.flatMap { $0.naturalSize.height }.flatMap(String.init)
        ]
        if isForAlbum { rupload["for_album"] = "1" }
        let header = [
            "X_FB_VIDEO_WATERFALL_ID": waterfallIdentifier,
            "X-Entity-Type": "video/mp4",
            "X-Instagram-Rupload-Params": try? rupload.wrapped.jsonRepresentation(),
            "X-Entity-Name": name,
            "Content-Type": "application/octet-stream",
            "Accept-Encoding": "gzip"
        ]
        // Return the first endpoint.
        let duration = TimeInterval(video.duration.seconds)
        return .init(identifier: identifier, name: name, size: size, date: now, duration: duration) { input in
            Request.api
                .path(appending: "rupload_igvideo")
                .path(appending: name)
                .appendingDefaultHeader()
                .header(appending: header)
                .header(appending: input.secret.header)
                .header(appending: input.secret.identifier, forKey: "IG-U-DS-User-ID")
                .publish(with: input.session)
                .map(\.data)
                .wrap()
                .flatMap { output -> AnyPublisher<Wrapper, Error> in
                    // Actually upload the video.
                    guard let offset = output.offset.int() else {
                        return Fail(error: Endpoint.Group.Media.Error.artifact(output)).eraseToAnyPublisher()
                    }
                    // Fetch the video and then upload it.
                    return Request(url)
                        .publish(with: input.session)
                        .map(\.data)
                        .flatMap {
                            Request.api
                                .path(appending: "rupload_igvideo")
                                .path(appending: name)
                                .appendingDefaultHeader()
                                .header(appending: header)
                                .header(appending: input.secret.header)
                                .header(appending: input.secret.identifier,
                                        forKey: "IG-U-DS-User-ID")
                                .header(appending: ["Offset": String(offset),
                                                    "X-Entity-Length": String($0.count),
                                                    "Content-Length": String($0.count)])
                                .body($0)
                                .publish(with: input.session)
                                .map(\.data)
                                .wrap()
                        }
                        .eraseToAnyPublisher()
                }
                .map(Media.Unit.init)
                .flatMap { output -> AnyPublisher<Media.Unit, Error> in
                    // Upload the preview.
                    guard output.error == nil else {
                        return Fail(error: Endpoint.Group.Media.Error.artifact(output.wrapper())).eraseToAnyPublisher()
                    }
                    return self.upload(image: preview,
                                       identifier: identifier,
                                       waterfallIdentifier: waterfallIdentifier)
                        .generator(input)
                        .eraseToAnyPublisher()
                }
                .flatMap { output -> AnyPublisher<Media.Unit, Error> in
                    // Finish uploading process.
                    guard output.error == nil else {
                        return Fail(error: Endpoint.Group.Media.Error.artifact(output.wrapper())).eraseToAnyPublisher()
                    }
                    let retryContext = #"{"num_step_auto_retry":0,"num_reupload":0,"num_step_manual_retry":0}"#
                    return Request.media
                        .path(appending: "upload_finish/")
                        .header(appending: input.secret.header)
                        .header(appending: ["retry_context": retryContext])
                        .query(appending: "1", forKey: "video")
                        .signing(body: ["timezone_offset": "43200",
                                        "_csrftoken": input.secret["csrftoken"].wrapped,
                                        "user_id": identifier.wrapped,
                                        "_uid": identifier.wrapped,
                                        "device_id": input.secret.client.device.instagramIdentifier.wrapped,
                                        "_uuid": input.secret.client.device.identifier.uuidString.wrapped,
                                        "upload_id": identifier.wrapped,
                                        "clips": [["length": duration.wrapped, "source_type": sourceType.wrapped]],
                                        "source_type": sourceType.wrapped,
                                        "length": Int(duration).wrapped,
                                        "poster_frame_index": 0,
                                        "audio_muted": false].wrapped)
                        .publish(with: input.session)
                        .map(\.data)
                        .wrap()
                        .map(Media.Unit.init)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
    }
    // swiftlint:enable function_body_length

    #endif
}

extension Endpoint.Group.Uploader {
    /// A module-like `enum` listing upload media respones.
    enum Upload { }
}

extension Endpoint.Group.Uploader.Upload {
    /// An alias for the generator input type.
    typealias Input = (secret: Secret, session: SessionProviderInput)

    /// A `struct` defining an image response.
    struct Image {
        /// The identifier.
        let identifier: String
        /// The name.
        let name: String
        /// The creation date.
        let date: Date
        /// A generator.
        let generator: (Input) -> AnyPublisher<Media.Unit, Error>
    }

    /// A `struct` defining a video response.
    struct Video {
        /// The identifier.
        let identifier: String
        /// The name.
        let name: String
        /// The size.
        let size: CGSize
        /// The creation date.
        let date: Date
        /// The duration.
        let duration: TimeInterval
        /// A generator.
        let generator: (Input) -> AnyPublisher<Media.Unit, Error>
    }
}
