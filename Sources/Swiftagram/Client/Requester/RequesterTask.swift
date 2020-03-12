//
//  RequesterTask.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 11/03/2020.
//

import Foundation

public extension Requester {
    /// A `class` holding reference to an endpoint fetching, pausable and cancellable, task.
    final class Task: Hashable {
        /// The response.
        public typealias Response<Data> = (data: Data, response: HTTPURLResponse?)
        /// The result.
        public typealias Result<Data> = Swift.Result<Response<Data>, Swift.Error>

        /// The task identifier.
        internal var identifier = UUID().uuidString

        /// The originating `Endpoint`.
        public let originating: Endpoint
        /// The current `Endpoint`.
        public var current: Endpoint?

        /// A weak reference to the `Requester`.
        public weak var requester: Requester?
        /// The current `URLSessionDataTask`.
        internal var sessionTask: URLSessionDataTask?
        /// A block requesting the next `Endpoint`.
        internal var next: (Result<Data>) -> Endpoint?

        // MARK: Lifecycle
        /// Deinit.
        deinit { cancel() }

        /// Init.
        /// - parameters:
        ///     - endpoint: The originating `Endpoint`.
        ///     - requester: A valid `Requester`. Defaults to `.default`.
        ///     - next: A block outputting the last response and requesting the following `Endpoint`. `nil` to stop.
        internal init(endpoint: Endpoint,
                      requester: Requester = .default,
                      next: @escaping (Result<Data>) -> Endpoint?) {
            self.originating = endpoint
            self.current = endpoint
            self.requester = requester
            self.next = next
        }

        // MARK: Handling
        /// Cancel the current and all future requests.
        public func cancel() {
            self.requester?.cancel(self)
            self.sessionTask?.cancel()
            self.sessionTask = nil
            self.current = nil
        }

        /// Cancel the current request.
        public func pause() {
            self.sessionTask?.cancel()
            self.sessionTask = nil
        }

        /// Fetch the `current` endpoint.
        /// - returns: `self` if there are no active tasks, `Endpoint` was valid and `requester` was not deallocated, `nil` otherwise.
        @discardableResult
        public func resume() -> Task? {
            guard sessionTask == nil,
                let endpoint = current,
                endpoint.request() != nil,
                let requester = requester else {
                    return nil
            }
            /// Add to the `requester`.
            requester.schedule(self)
            return self
        }

        // MARK: Fetching
        /// Fetch using a given `session`.
        /// - parameters:
        ///     - session: A `URLSession`.
        ///     -  configuration: A `Requester.Configuration`.
        internal func fetch(using session: URLSession,
                            configuration: Requester.Configuration) {
            // Check for a valid `URL`.
            guard let request = current?.request() else {
                configuration.mapQueue.handle { [weak self] in
                    self?.current = self?.next(.failure(Error.invalidEndpoint))
                    self?.pause()
                    configuration.requestQueue.handle { self?.resume() }
                }
                return
            }
            // Set `task`.
            configuration.requestQueue.handle {
                self.sessionTask = session.dataTask(with: request) { [weak self] data, response, error in
                    configuration.mapQueue.handle {
                        if let error = error {
                            self?.current = self?.next(.failure(error))
                        } else if let data = data {
                            self?.current = self?.next(.success((data, response as? HTTPURLResponse)))
                        } else {
                            self?.current = self?.next(.failure(Error.invalidData))
                        }
                        self?.pause()
                        configuration.requestQueue.handle { self?.resume() }
                    }
                }
                self.sessionTask?.resume()
            }
        }

        // MARK: Hashable
        /// Conform to hashable.
        public func hash(into hasher: inout Hasher) { hasher.combine(identifier) }
        /// Conform to equatable.
        public static func ==(lhs: Task, rhs: Task) -> Bool { return lhs.identifier == rhs.identifier }
    }
}
