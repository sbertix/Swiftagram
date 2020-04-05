//
//  RequestExtensions.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 05/04/2020.
//

import Foundation

import ComposableRequest

/// **Instagram** specific accessories for `Composable`.
public extension Composable {
    /// Append to `headerFields`.
    func defaultHeader() -> Self {
        return header(
            ["Accept-Language": "en-US",
             "Content-Type": "application/x-www-form-urlencoded",
             "X-IG-Capabilities": "3brTvw==",
             "X-IG-Connection-Type": "WIFI",
             "User-Agent": ["Instagram 85.0.0.21.100 Android ",
                            "(21/5.0.2; 640dpi; 1440x2560; Sony; C6603; C6603; qcom; en_US; 95414346)"]
                .joined()]
        )
    }
}

/// **Instagram** specific accessories for `Requester`.
public extension Requester {
    /// An **Instagram** `Requester` matching `.default` with a longer, safer, `waiting` range.
    static let instagram = Requester(configuration: .init(sessionConfiguration: .default,
                                                          requestQueue: .main,
                                                          mapQueue: .global(qos: .userInitiated),
                                                          responseQueue: .main,
                                                          waiting: 0.5...1.5))
}
