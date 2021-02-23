//
//  EndpointMediaComponents.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 29/08/20.
//

import Foundation

#if canImport(AVFoundation) && canImport(CoreGraphics)
import AVFoundation
import CoreGraphics
#endif

import ComposableRequest
import Swiftagram

/// An `internal` extension providing reusable code for media upload and configuration.
extension Endpoint.Media {
    /// The base endpoint.
    private static var base: Request { Endpoint.version1.media.appendingDefaultHeader() }

    /// Upload an image `data` with size `size`.
    ///
    /// - note: Make sure the `Future` generator is only ever called inside `Deferred`, otherwise it will fetch immediately.
    /// - parameters:
    ///     - data: Some `Data` representing a `jpeg` image.
    ///     - identifier: An optional `uploadId`. Defaults to `nil`.
    ///     - waterfallIdentifier: An optional `waterfallIdentifier`. Defaults to `nil`
    /// - returns: A `Media.Unit` `Disposable`, `identifier`, `name` and `date`.
    static func upload(image data: Data,
                       identifier: String? = nil,
                       waterfallIdentifier: String? = nil) -> Upload.Image {
        /// Prepare upload parameters.
        let now = Date()
        let identifier = identifier ?? String(Int(now.timeIntervalSince1970*1_000))
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
            Endpoint.api
                .path(appending: "rupload_igphoto")
                .path(appending: name)
                .appendingDefaultHeader()
                .header(appending: header)
                .header(appending: input.secret.header)
                .header(appending: input.secret.identifier, forKey: "IG-U-DS-User-ID")
                .body(data)
                .project(input.session)
                .map(\.data)
                .wrap()
                .map(Media.Unit.init)
                .observe(on: input.session.scheduler)
                .eraseToAnyProjectable()
        }
    }

    #if canImport(AVFoundation) && canImport(CoreGraphics)

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
    static func upload(video url: URL,
                       preview data: Data?,
                       previewSize: CGSize,
                       sourceType: String,
                       isForAlbum: Bool = false) -> Upload.Video {
        // Prepare upload parameters.
        let video = AVAsset(url: url)
        let now = Date()
        let identifier = String(Int(now.timeIntervalSince1970*1_000))
        let waterfallIdentifier = UUID().uuidString
        let name = identifier+"_0_\(Int64.random(in: 1_000_000_000...9_999_999_999))"
        let track = video.tracks(withMediaType: .video).first
        let size = CGSize(width: track?.naturalSize.width ?? 0, height: track?.naturalSize.height ?? 0)
        guard let preview = data ?? Agnostic.Color.black.image(size: size).jpegRepresentation() else { fatalError("Invalid preview.") }
        precondition(size == previewSize || data == nil, "Preview \(previewSize) and video \(size) must have the same width and height.")
        // Prepare the header.
        var rupload = [
            "retry_context": #"{"num_step_auto_retry":0,"num_reupload":0,"num_step_manual_retry":0}"#,
            "media_type": "2",
            "upload_id": identifier,
            "waterfall_id": waterfallIdentifier,
            "xsharing_user_ids": "[]",
            "image_compression": #"{"lib_name":"moz","lib_version":"3.1.m","quality":"80"}"#,
            "upload_media_durations_ms": "\(Int(video.duration.seconds*1000))",
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
            Endpoint.api
                .path(appending: "rupload_igvideo")
                .path(appending: name)
                .appendingDefaultHeader()
                .header(appending: header)
                .header(appending: input.secret.header)
                .header(appending: input.secret.identifier, forKey: "IG-U-DS-User-ID")
                .project(input.session)
                .map(\.data)
                .wrap()
                .flatMap { output -> AnyProjectable<Wrapper, Error> in
                    // Actually upload the video.
                    guard let offset = output.offset.int() else {
                        return Projectables.Fail(MediaError.artifact(output)).eraseToAnyProjectable()
                    }
                    // Fetch the video and then upload it.
                    return Request(url)
                        .project(session: input.session.session,
                                 on: Scheduler.queue(.userInitiated),
                                 logging: input.session.logger)
                        .map(\.data)
                        .flatMap { output -> AnyProjectable<Data, Error> in
                            guard let output = output else {
                                return Projectables.Fail(MediaError.videoNotFound).eraseToAnyProjectable()
                            }
                            return Projectables.Just(output).eraseToAnyProjectable()
                        }
                        .flatMap {
                            Endpoint.api
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
                                .project(input.session)
                                .map(\.data)
                                .wrap()
                        }
                        .eraseToAnyProjectable()
                }
                .map(Media.Unit.init)
                .flatMap { output -> AnyProjectable<Media.Unit, Error> in
                    // Upload the preview.
                    guard output.error == nil else {
                        return Projectables.Fail(MediaError.artifact(output.wrapper())).eraseToAnyProjectable()
                    }
                    return upload(image: preview,
                                  identifier: identifier,
                                  waterfallIdentifier: waterfallIdentifier)
                        .generator(input)
                        .eraseToAnyProjectable()
                }
                .flatMap { output -> AnyProjectable<Media.Unit, Error> in
                    // Finish uploading process.
                    guard output.error == nil else {
                        return Projectables.Fail(MediaError.artifact(output.wrapper())).eraseToAnyProjectable()
                    }
                    return base.path(appending: "upload_finish/")
                        .header(appending: input.secret.header)
                        .header(appending: ["retry_context": #"{"num_step_auto_retry":0,"num_reupload":0,"num_step_manual_retry":0}"#])
                        .query(appending: "1", forKey: "video")
                        .signing(body: ["timezone_offset": "43200",
                                        "_csrftoken": input.secret["csrftoken"]!.wrapped,
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
                        .project(input.session)
                        .map(\.data)
                        .wrap()
                        .map(Media.Unit.init)
                        .eraseToAnyProjectable()
                }
                .observe(on: input.session.scheduler)
                .eraseToAnyProjectable()
        }
    }

    #endif
}

extension Endpoint.Media {
    /// A module-like `enum` listing upload media respones.
    enum Upload {
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
            let generator: (Input) -> AnyProjectable<Media.Unit, Error>
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
            let generator: (Input) -> AnyProjectable<Media.Unit, Error>
        }
    }
}
