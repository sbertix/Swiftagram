//
//  EndpointCombine.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

#if canImport(Combine)
import Combine
import Foundation

/// A `class` defining a new `Subscription` specific for `Response`s coming from `Endpoint` requests.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class EndpointSubscription<Subscriber: Combine.Subscriber, Response: DataMappable>: Subscription
where Subscriber.Input == Response, Subscriber.Failure == Error {
    /// A `Requester.Task`.
    private var task: Requester.Task?
    /// A `Subscriber`.
    private var subscriber: Subscriber?

    // MARK: Lifecycle
    /// Init.
    /// - parameters:
    ///     - request: A valid `Endpoint`.
    ///     - subscriber: The `Subscriber`.
    public init(request: Endpoint, subscriber: Subscriber) {
        self.subscriber = subscriber
        self.task = request.task(Response.self) {
            switch $0 {
            case .failure(let error): subscriber.receive(completion: .failure(error))
            case .success(let success):
                _ = subscriber.receive(success.data)
                subscriber.receive(completion: .finished)
            }
        }
        self.task?.resume()
    }

    // MARK: Subscription
    /// Request. The default implementation does nothing.
    public func request(_ demand: Subscribers.Demand) { }

    /// Cancel.
    public func cancel() {
        self.task = nil
        self.subscriber = nil
    }
}

/// A `struct` defining a new `Publisher` specific for `Response`s coming from`Endpoint` requests.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct EndpointPublisher<Response: DataMappable>: Publisher {
    /// Output a `Response` item.
    public typealias Output = Response
    /// Fail to any `Error`.
    public typealias Failure = Error

    /// A valid `Endpoint`.
    private var request: Endpoint

    /// Init.
    /// - parameter request: A valid `Endpoint`.
    public init(request: Endpoint) { self.request = request }

    /// Receive the `Subscriber`.
    /// - parameter subscriber: A valid `Subscriber`.
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: EndpointSubscription(request: request, subscriber: subscriber))
    }
}

/// A combine extension for `Request`.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Endpoint {
    /// Return a `Response` publisher.
    /// - parameter response: A `DataMappable` concrete type.
    func publish<Response: DataMappable>(response: Response.Type) -> EndpointPublisher<Response> {
        return EndpointPublisher(request: self)
    }

    /// Return a `Response` publisher.
    func publish() -> EndpointPublisher<Response> {
        return EndpointPublisher(request: self)
    }
}

#endif
