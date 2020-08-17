//
//  Requester.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 01/08/20.
//

import Foundation

import ComposableRequest

/// **Instagram** specific accessories for `Requester`.
public extension Requester {
    /// The `URLSessionConfiguration` used for `.instagram`.
    private static let instagramSessionConfiguration: URLSessionConfiguration = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpMaximumConnectionsPerHost = 2
        return sessionConfiguration
    }()
    /// An **Instagram** `Requester` matching `.default` with a longer, safer, `waiting` range.
    static let instagram = Requester(configuration: .init(sessionConfiguration: instagramSessionConfiguration,
                                                          dispatcher: .init(),
                                                          waiting: 0.5...1.5))
}
