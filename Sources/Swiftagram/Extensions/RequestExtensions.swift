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
             "User-Agent": Device.default.apiUserAgent]
        )
    }
}

/// **Instagram** specific accessories for `Requester`.
public extension Requester {
    /// An **Instagram** `Requester` matching `.default` with a longer, safer, `waiting` range.
    static let instagram = Requester(configuration: .init(sessionConfiguration: .default,
                                                          dispatcher: .init(),
                                                          waiting: 0.5...1.5))
}

/// `Unlockable` extension.
public extension Unlockable {
    /// Unlock using `Key`.
    /// - parameter key: A valid `Key`.
    /// - returns: The authenticated `Locked`.
    /// - warning: `authenticating` will be removed in the next minor.
    @available(*, deprecated, renamed: "unlocking")
    func authenticating(with key: Key) -> Locked {
        return unlocking(with: key)
    }
}
