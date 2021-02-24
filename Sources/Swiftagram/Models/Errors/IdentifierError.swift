//
//  IdentifierError.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 24/02/21.
//

import Foundation

public extension Endpoint.Media.Posts {
    /// An `enum` listing all identifier-related errors.
    enum IdentifierError: Error {
        /// The `URL` either does not contain a `p` directory,
        /// or it's in last position.
        case invalidURL(URL)
        /// The shortcode contains invalid characters.
        case invalidShortcode(String)
    }
}
