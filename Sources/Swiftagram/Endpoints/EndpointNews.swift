//
//  EndpointNews.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

import ComposableRequest

public extension Endpoint {
    /// A `struct` holding reference to `news` `Endpoint`s. Requires authentication.
    struct News {
        /// The base endpoint.
        private static let base = Endpoint.version1.news.appendingDefaultHeader()

        /// The current inbox.
        public static var inbox: DisposableResponse = base.inbox.prepare().locking(Secret.self)
    }
}
