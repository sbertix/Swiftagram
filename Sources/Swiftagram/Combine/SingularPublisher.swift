//
//  SingularPublisher.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

#if canImport(Combine)
import Combine
import Foundation

/// A `struct` defining a new `Publisher` specific for `Response`s coming from`Endpoint` requests.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct SingularPublisher<Request: Composable & Requestable & Singular>: Publisher {
    /// Output a `Response` item.
    public typealias Output = Request.Response
    /// Fail to any `Error`.
    public typealias Failure = Error

    /// A valid `Endpoint`.
    private var request: Request

    /// Init.
    /// - parameter request: A valid `Endpoint`.
    public init(request: Request) { self.request = request }

    /// Receive the `Subscriber`.
    /// - parameter subscriber: A valid `Subscriber`.
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: SingularSubscription(request: request, subscriber: subscriber))
    }
}

/// A combine extension for `Request`.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Composable where Self: Requestable, Self: Singular {
    /// Return a `Response` publisher.
    func publish() -> SingularPublisher<Self> {
        return SingularPublisher(request: self)
    }
}

/// A combine extension for `Request`.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Paginatable where Originating: Composable & Requestable {
    /// Return a `Response` publisher.
    func publishOnce() -> SingularPublisher<Expected<Originating, Response>> {
        return SingularPublisher(request: self.once())
    }
}
#endif
