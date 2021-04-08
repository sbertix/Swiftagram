//
//  Endpoint+ManyComments.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/04/21.
//

import Foundation

public extension Endpoint.Group.Media {
    /// A `class` defining multiple comments endpoints.
    final class ManyComments {
        /// The media.
        public let media: Endpoint.Group.Media
        /// A list of comment identifiers.
        public let identifiers: [String]

        /// Init.
        ///
        /// - parameters:
        ///     - media: A valid `Endpoint.Group.Media`.
        ///     - identifiers: An array of `String`s.
        init(media: Endpoint.Group.Media,
             identifiers: [String]) {
            self.media = media
            self.identifiers = identifiers
        }
    }

    /// A wrapper for comments-specific endpoints.
    ///
    /// - parameter identifiers: A collection of `String`s.
    /// - returns: A valid `Endpoint.ManyComments`.
    func comments<C: Collection>(_ identifiers: C) -> ManyComments where C.Element == String {
        .init(media: self, identifiers: Array(identifiers))
    }
}
