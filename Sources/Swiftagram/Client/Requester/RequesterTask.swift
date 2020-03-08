//
//  RequesterTask.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

public extension Requester {
    /// A `struct` holding reference to a specific `Request`.
    final class Task: Hashable {
        /// A `tuple` holding reference to responses.
        public typealias Response<Type> = (data: Type, response: HTTPURLResponse?)

        /// A `String` representing the current `hashValue`.
        internal var identifier: String = UUID().uuidString
        /// A `Date` indicating when the `Request` was first resumed.
        public internal(set) var startedAt: Date = .init()
        /// An associated `Request`.
        public internal(set) var request: Request

        // MARK: Lifecycle
        /// Cancel on `deinit`.
        deinit { cancel() }
        
        /// Init.
        /// - parameter request: A valid `Request`.
        public init(request: Request) { self.request = request }

        /// Cancel the current request.
        public func cancel() {
            request.task?.cancel()
            request.requester?.requests.remove(self)
        }

        // MARK: Hashable
        public func hash(into hasher: inout Hasher) { hasher.combine(identifier) }
        public static func ==(lhs: Task, rhs: Task) -> Bool { return lhs.identifier == rhs.identifier }
    }
}
