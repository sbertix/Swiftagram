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

    /// A set of `Task`s currently scheduled or undergoing fetching.
    internal var requests: Set<Task> = [] {
        didSet {
            let inserted = requests.subtracting(oldValue)
            let session = configuration.session
            // Actually fetch `inserted` tasks.
            inserted.forEach { task in
                task.request.fetch(using: session, configuration: configuration) { [weak self] in
                    // Remove the task once it's done.
                    self?.requests.remove(task)
                }
            }
        }
    }

    // MARK: Lifecycle
    /// Deinit.
    deinit {
        /// Cancell all tasks.
        requests = []
    }

    /// Init.
    /// - parameter configuration: A valid `Configuration`.
    public init(configuration: Configuration = .default) { self.configuration = configuration }

    // MARK: Schedule
    /// Schedule a new `request`.
    /// - parameter request: A valid `Request`.
    @discardableResult
    internal func schedule(_ request: Request) -> Task {
        return requests.insert(Task(request: request)).memberAfterInsert
    }
}
