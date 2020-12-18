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

//swiftlint:disable large_tuple
/// An `internal` extension providing reusable code for media upload and configuration.
extension Endpoint.Media {
    /// The base endpoint.
    private static var base: Request { Endpoint.version1.media.appendingDefaultHeader() }

    /// Upload an image `data` with size `size`.
    /// - parameters:
    ///     - data: Some `Data` representing a `jpeg` image.
    ///     - identifier: An optional `uploadId`. Defaults to `nil`.
    ///     - waterfallIdentifier: An optional `waterfallIdentifier`. Defaults to `nil`
    /// - returns: A `Media.Unit` `Disposable`, `identifier`, `name` and `date`.
    /// - warning: Remember to set `Secret` specific headers in the request.
    static func upload(image data: Data,
                       identifier: String? = nil,
                       waterfallIdentifier: String? = nil) -> (fetcher: Fetcher<Request, Media.Unit>.Disposable,
                                                               identifier: String,
                                                               name: String,
                                                               date: Date) {
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
        /// Return the first endpoint.
        return (fetcher: Endpoint.api
                    .appending(path: "rupload_igphoto")
                    .appending(path: name)
                    .appendingDefaultHeader()
                    .appending(header: header)
                    .replacing(body: data)
                    .prepare(process: Media.Unit.self),
                identifier: identifier,
                name: name,
                date: now)
    }

    #if canImport(AVFoundation) && canImport(CoreGraphics)
    @available(watchOS 6, *)
    /// Upload video at `url`.
    /// - parameters:
    ///     - url: Some `url` to an `.mp4` video.
    ///     - data: Some `Data` representing a `jpeg` preview of the video.
    ///     - previewSize: A `CGSize` holding reference to the preview size.
    ///     - isForAlbum: A `Bool`.
    /// - returns: A `Media.Unit` `Disposable`, `identifier`, `name` and `date`.
    /// - warning: Remember to set `Secret` specific headers in the request.
    static func upload(video url: URL,
                       preview data: Data?,
                       previewSize: CGSize,
                       isForAlbum: Bool = false) -> (fetcher: Fetcher<Request, Media.Unit>.Disposable,
                                                     identifier: String,
                                                     name: String,
                                                     date: Date,
                                                     duration: TimeInterval,
                                                     size: CGSize) {
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
        return (fetcher: Endpoint.api
                    .appending(path: "rupload_igvideo")
                    .appending(path: name)
                    .appendingDefaultHeader()
                    .appending(header: header)
                    .prepare(process: Media.Unit.self)
                    .switch {
                        // Actually upload the data.
                        guard let response = try? $0.get(),
                              let offset = response.offset.int(),
                              let data = try? Data(contentsOf: url) else { return nil }
                        // The actual configuration will be performed by the preprocessor on `unlocking`.
                        return Endpoint.api
                            .appending(path: "rupload_igvideo")
                            .appending(path: name)
                            .appending(header: header)
                            .appending(header: ["Offset": String(offset),
                                                "X-Entity-Length": String(data.count),
                                                "Content-Length": String(data.count) ])
                            .replacing(body: data)
                    }
                    .switch {
                        // Upload the picture.
                        guard let response = try? $0.get(), response.error == nil else { return nil }
                        // The actual configuration will be performed by the preprocessor on `unlocking`.
                        return upload(image: preview,
                                      identifier: identifier,
                                      waterfallIdentifier: waterfallIdentifier).fetcher.request
                    }
                    .switch {
                        // Finish the upload.
                        guard let response = try? $0.get(), response.error == nil else { return nil }
                        // The actual configuration will be performed by the preprocessor on `unlocking`.
                        return base
                            .appending(path: "upload_finish/")
                            .appending(header: ["retry_context": #"{"num_step_auto_retry":0,"num_reupload":0,"num_step_manual_retry":0}"#])
                            .appending(query: ["video": "1"])
                    },
                identifier: identifier,
                name: name,
                date: now,
                duration: TimeInterval(video.duration.seconds),
                size: size)
    }
    #endif
}
//swiftlint:enable large_tuple
