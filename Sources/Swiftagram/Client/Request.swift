//
//  Request.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 04/01/2020.
//

import Foundation

/// A `class` binding a specific Instagram endpoint to an `Account`.
public final class Request {
    /// An `enum` holding reference to possible completion types.
    internal enum Completion {
        /// Data and response.
        case data((Result<(data: Data, response: HTTPURLResponse?), Swift.Error>) -> Void)
        /// Dynamic response.
        case response((Result<(data: Response, response: HTTPURLResponse?), Swift.Error>) -> Void)

        /// Parse `Data` into the `Completion` specific block input and then call it.
        internal func send(_ data: Result<(data: Data, response: HTTPURLResponse?), Swift.Error>) {
            switch self {
            case .data(let send): send(data)
            case .response(let send): send(data.map { ((try? Response(data: $0.data)) ?? .none, $0.response) })
            }
        }
    }
    /// An `enum` holding reference to `Request`-specific `Error`s.
    public enum Error: Swift.Error {
        /// Invalid `Data`.
        case invalidData
        /// Invalid `URL`.
        case invalidEndpoint
    }

    /// The current endpoint.
    public internal(set) var endpoint: Endpoint
    /// The block to be called when results are fetched.
    internal var onComplete: Completion?
    /// The `Requester` used to carry out the `Request`. Defaults to `.default`.
    internal weak var requester: Requester?
    /// An optional `URLSessionDataTask`. Defaults to `nil`.
    internal var task: URLSessionTask?

    // MARK: Lifecycle
    /// Deinit.
    deinit {
        // Invalidate all requests on `deinit`
        task?.cancel()
    }
    /// Init.
    /// - parameter endpoint: A valid `Endpoint`.
    public init(_ endpoint: Endpoint, through requester: Requester = .default) {
        self.endpoint = endpoint
        self.requester = requester
    }

    // MARK: Composition
    /// Authenticate `self` through the authentication `response`.
    /// - parameter response: An `Authentication.Response`.
    public func authenticating(with response: Authentication.Response) -> Request {
        precondition(self.task == nil, "`Request.authenticating` can only be called before resuming")
        self.endpoint = endpoint.headerFields(response.headerFields)
        return self
    }

    /// Add completion block.
    /// - parameter onComplete: A block accepting `Result<Data, Error>`.
    public func onDataComplete(_ onComplete: @escaping (Result<(data: Data, response: HTTPURLResponse?), Swift.Error>) -> Void) -> Request {
        precondition(self.task == nil, "`Request.onComplete` can only be called before resuming")
        self.onComplete = .data(onComplete)
        return self
    }
    /// Add completion block.
    /// - parameter onComplete: A block accepting `Result<Response, Error>`.
    public func onComplete(_ onComplete: @escaping (Result<(data: Response, response: HTTPURLResponse?), Swift.Error>) -> Void) -> Request {
        precondition(self.task == nil, "`Request.onComplete` can only be called before resuming")
        self.onComplete = .response(onComplete)
        return self
    }

    // MARK: Schedule
    @discardableResult
    /// Create a new `Requester.Task` and start fetching data.
    public func resume() -> Requester.Task {
        precondition(self.task == nil, "`Request.resume` can only be called once")
        return (requester ?? .default).schedule(self)
    }

    /// Fetch using a given `session`.
    /// - parameter session: A `URLSession`.
    internal func fetch(using session: URLSession, onComplete: @escaping () -> Void) {
        // Check for a valid `URL`.
        guard let request = endpoint.request else {
            self.onComplete?.send(.failure(Error.invalidEndpoint))
            return onComplete()
        }
        // Set `task`.
        self.task = session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.onComplete?.send(.failure(error)); onComplete()
            } else if let data = data {
                self?.onComplete?.send(.success((data, response as? HTTPURLResponse))); onComplete()
            } else {
                self?.onComplete?.send(.failure(Error.invalidData))
                onComplete()
            }
        }
        self.task?.resume()
    }
}
