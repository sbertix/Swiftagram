//
//  RequesterConfiguration.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

public extension Requester {
    /// A `struct` defining a `Requester` settings.
    struct Configuration: Hashable {
        /// The default implementation for `Configuration`.
        public static let `default` = Configuration(sessionConfiguration: .default,
                                                    requestQueue: .current,
                                                    mapQueue: .global(qos: .userInitiated),
                                                    responseQueue: .main)

        /// A `URLSessionConfiguration`.
        public var sessionConfiguration: URLSessionConfiguration
        /// A valid `Queue` in which to perform requests.
        public var requestQueue: Queue
        /// A valid `Queue` in which to perform a `Completion`'s `Data` manipulation.
        public var mapQueue: Queue
        /// A valid `Queue` in which to deliver responses.
        public var responseQueue: Queue

        // MARK: Accessories
        /// Return an associated `URLSession`.
        public var session: URLSession { return URLSession(configuration: sessionConfiguration) }
    }
}
