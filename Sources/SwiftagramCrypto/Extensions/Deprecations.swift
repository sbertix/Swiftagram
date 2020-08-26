//
//  Deprecations.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 26/08/20.
//

import CoreGraphics
import Foundation

import Swiftagram

public extension Endpoint.Media.Posts {
    /// Delete the media matching `identifier`.
    /// - parameter identifier: A valid media identifier.
    @available(*, deprecated, message: "use `Endpoint.Media.Posts` instead")
    static func delete(matching identifier: String) -> Endpoint.Disposable<Status> {
        return Endpoint.Media.delete(matching: identifier)
    }

    /// Upload `image` to Instagram.
    /// - parameters:
    ///     - image: A `Data` representation of an image.
    ///     - size: A `CGSize` holding `width` and `height` of the original image.
    ///     - caption: An optional `String` holding the post's caption.
    ///     - users: An optional collection of `UserTag`s. Defaults to `nil`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    @available(*, deprecated, renamed: "upload(image:size:captioned:tagging:at:)")
    static func upload<U: Collection>(image data: Data,
                                      with size: CGSize,
                                      captioned caption: String?,
                                      tagging users: U?,
                                      at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> where U.Element == UserTag {
        return upload(image: data, size: size, captioned: caption, tagging: users, at: location)
    }

    /// Upload `image` to Instagram.
    /// - parameters:
    ///     - image: A `Data` representation of an image.
    ///     - size: A `CGSize` holding `width` and `height` of the original image.
    ///     - caption: An optional `String` holding the post's caption.
    ///     - users: An optional collection of `UserTag`s. Defaults to `nil`.
    ///     - location: An optional `Location`. Defaults to `nil`.
    @available(*, deprecated, renamed: "upload(image:size:captioned:at:)")
    static func upload(image data: Data,
                       with size: CGSize,
                       captioned caption: String?,
                       at location: Location? = nil) -> Endpoint.Disposable<Media.Unit> {
        return upload(image: data, size: size, captioned: caption, tagging: [], at: location)
    }
}
