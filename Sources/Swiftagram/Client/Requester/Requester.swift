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
    /// A `URLSessionConfiguration`.
    public var configuration: URLSessionConfiguration
    /// A `URLSession` to use for requests. Defaults to `.shared`.
    public var session: URLSession { return URLSession(configuration: configuration) }
    /// A set of `Task`s currently scheduled or undergoing fetching.
    internal var requests: Set<Task> = [] {
        didSet {
            let inserted = requests.subtracting(oldValue)
            // Actually fetch `inserted` tasks.
            inserted.forEach { task in
                task.request.fetch(using: session) { [weak self] in
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
    public init(configuration: URLSessionConfiguration = .default) { self.configuration = configuration }

    // MARK: Schedule
    @discardableResult
    /// Schedule a new `request`.
    /// - parameter request: A valid `Request`.
    internal func schedule(_ request: Request) -> Task {
        return requests.insert(Task(request: request)).memberAfterInsert
    }
}
