//
//  PaginatablePublisher.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 16/03/2020.
//

#if canImport(Combine)
import Combine
import Foundation

/// A `struct` defining a new `Publisher` specific for `Response`s coming from`Endpoint` requests.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct PaginatablePublisher<Request: Composable & Requestable & Paginatable>: Publisher {
    /// Output a `Response` item.
    public typealias Output = Request.Response
    /// Fail to any `Error`.
    public typealias Failure = Error

    /// A valid `Endpoint`.
    private var request: Request
    /// A valid `Requester`.
    private weak var requester: Requester?

    /// Init.
    /// - parameter request: A valid `Endpoint`.
    public init(request: Request, requester: Requester) {
        self.request = request
        self.requester = requester
    }

    /// Receive the `Subscriber`.
    /// - parameter subscriber: A valid `Subscriber`.
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: PaginatableSubscription(request: request,
                                                                 requester: requester,
                                                                 subscriber: subscriber))
    }
}

/// A combine extension for `Request`.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Paginatable where Self: Composable & Requestable {
    /// Return a `Response` publisher.
    /// - parameter requester: A valid `Requester`. Defaults to `.default`.
    /// - note: Call `.prefix(_)` or `.first()` to control the maximum amount of outputs to receive, otherwise it will exhaust them before completing.
    func publish(in requester: Requester = .default) -> PaginatablePublisher<Self> {
        return PaginatablePublisher(request: self, requester: requester)
    }
}

/// A combine extension for `Request`.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Composable where Self: Requestable, Self: Singular {
    /// Return a `Response` publisher.
    /// - parameter requester: A valid `Requester`. Defaults to `.default`.
    func publish(in requester: Requester = .default) -> PaginatablePublisher<Paginated<Self, Response>> {
        /// Create a `Paginated` item the loads one value and completes.
        return PaginatablePublisher(request: self.paginating(key: "", initial: nil, next: { _ in nil }),
                                    requester: requester)
    }
}
#endif
