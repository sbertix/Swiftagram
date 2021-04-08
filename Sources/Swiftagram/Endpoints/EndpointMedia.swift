//
//  EndpointMedia.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

public extension Endpoint {
    /// A module-like `enum` holding reference to `media` `Endpoint`s. Requires authentication.
    enum Media {
        /// The base endpoint.
        static let base = Request.version1.media.appendingDefaultHeader()

        public enum Posts { }
    }
}
