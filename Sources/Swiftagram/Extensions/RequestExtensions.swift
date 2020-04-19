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

/// `Requestable & Paginatable` extension.
public extension Requestable where Self: Paginatable, Self: Composable {
    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - maxLength: The maximum amount of pages that should be returned. Pass `.max` to keep fetching until no next requet is found.
    ///     - requester: A valid `Requester`. Defaults to `.default`.
    ///     - onComplete: An optional block called when `maxLength` is reached or no next endpoint is provided.
    ///     - onChange: A block called everytime a new page is fetched.
    /// - returns: A `Requester.Task`. You need to `resume` it for it to start.
    @available(*, deprecated, renamed: "task")
    func cycleTask(maxLength: Int,
                   by requester: Requester = .default,
                   onComplete: ((_ length: Int) -> Void)? = nil,
                   onChange: @escaping (Result<Response, Error>) -> Void) -> Requester.Task {
        return self.task(maxLength: maxLength, by: requester, onComplete: onComplete, onChange: onChange)
    }
}
