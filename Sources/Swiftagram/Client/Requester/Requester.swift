//
//  Requester.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

/// A `class` used to perform `Request`s.
public final class Requester {
    /// A shared instance of `Requester` using `URLSession.shared`.
    public static let `default` = Requester()
    /// A `Configuration`. Defaults to `.default`.
    public var configuration: Configuration

    /// A set of `Requester.Task`s currently scheduled or undergoing fetching.
    private var tasks: Set<Requester.Task> = [] {
        didSet {
            let session = configuration.session
            /// Fetch `Requester.Task` as they're added.
            tasks.subtracting(oldValue).forEach { $0.fetch(using: session, configuration: configuration) }
        }
    }

    // MARK: Lifecycle
    /// Deinit.
    deinit {
        /// Cancell all tasks.
        tasks.forEach { $0.cancel() }
    }

    /// Init.
    /// - parameter configuration: A valid `Configuration`.
    public init(configuration: Configuration = .default) { self.configuration = configuration }

    // MARK: Schedule
    // MARK: Schedule
    /// Schedule a new `request`.
    /// - parameter request: A valid `Requester.Task`.
    internal func schedule(_ request: Requester.Task) {
        guard !tasks.insert(request).inserted else { return }
        request.fetch(using: configuration.session, configuration: configuration)
    }

    /// Cancel a given `request`.
    /// - parameter request: A valid `Requester.Task`.
    internal func cancel(_ request: Requester.Task) { tasks.remove(request) }
}
