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
import Requests
#endif

extension Endpoint.Group {
    /// A `class` defining shared code for the upload process.
    final class Uploader { }
}

extension Endpoint {
    /// A wrapper for uploader code.
    static var uploader: Group.Uploader { .init() }
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
                .prepare(with: input.requester)
                .map(\.data)
                .decode()
                .map(Media.Unit.init)
                .requested(by: input.requester)
        }
    }
}

extension Endpoint.Group.Uploader {
    /// A module-like `enum` listing upload media respones.
    enum Upload { }
}

extension Endpoint.Group.Uploader.Upload {
    /// An alias for the generator input type.
    typealias Input = (secret: Secret, requester: R)

    /// A `struct` defining an image response.
    struct Image {
        /// The identifier.
        let identifier: String
        /// The name.
        let name: String
        /// The creation date.
        let date: Date
        /// A generator.
        let generator: (Input) -> R.Requested<Media.Unit>
    }
}
