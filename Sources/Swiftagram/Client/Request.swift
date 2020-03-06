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
        /// Data.
        case data((Result<Data, Swift.Error>) -> Void)
        /// Dynamic response.
        case dynamic
        
        /// Parse `Data` into the `Completion` specific block input and then call it.
        internal func send(_ data: Result<Data, Swift.Error>) {
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
    public let endpoint: Endpoint
    /// The authentication cookies.
    internal var cookies: [HTTPCookie]?
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
    /// Authenticate `self` through a set of `HTTPCookie`s.
    public func authenticating(with cookies: [HTTPCookie]) -> Request {
        precondition(self.cookies == nil, "`Request.authenticating` can only be called once")
        self.cookies = cookies
        return self
    }
    /// Add completion block.
    public func onComplete(_ onComplete: @escaping (Result<Data, Swift.Error>) -> Void) -> Request {
        precondition(self.onComplete == nil, "`Request.onComplete` can only be called once")
        self.onComplete = .data(onComplete)
        return self
    }
    
    // MARK: Schedule
    @discardableResult
    /// Start fetching data.
    public func resume() -> Requester.Task {
        precondition(self.task == nil, "`Request.resume` can only be called once")
        return (requester ?? .default).schedule(self)
    }
    /// Fetch using a given `session`.
    /// - parameter session: A `URLSession`.
    internal func fetch(using session: URLSession, onComplete: @escaping () -> Void) {
        // Check for a valid `URL`.
        guard let url = endpoint.url else {
            self.onComplete?.send(.failure(Error.invalidEndpoint))
            return onComplete()
        }
        // Set `task`.
        self.task = session.dataTask(with: url) { [weak self] data, _, error in
            if let error = error { self?.onComplete?.send(.failure(error)); onComplete() }
            else if let data = data { self?.onComplete?.send(.success(data)); onComplete() }
            else { self?.onComplete?.send(.failure(Error.invalidData)); onComplete() }
        }
    }
}
