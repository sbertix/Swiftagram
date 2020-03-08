//
//  RequestCombine.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

#if canImport(Combine)
import Foundation
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
/// A combine extension for `Request`.
public extension Request {
    /// Return a `Response` publisher.
    func responsePublisher() -> RequestPublisher {
        return RequestPublisher(request: self)
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
/// A `class` defining a new `Subscription` specific for `Response`s coming from `Request`s.
public final class RequestSubscription<Subscriber: Combine.Subscriber>: Subscription where Subscriber.Input == Response, Subscriber.Failure == Error {
    /// A `Requester.Task`.
    private var task: Requester.Task?
    /// A `Subscriber`.
    private var subscriber: Subscriber?
    
    // MARK: Lifecycle
    /// Init.
    /// - parameter request: A valid `Request`.
    /// - parameter subscriber: The `Subscriber`.
    public init(request: Request, subscriber: Subscriber) {
        self.subscriber = subscriber
        self.task = request
            .onComplete {
                switch $0 {
                case .failure(let error): subscriber.receive(completion: .failure(error))
                case .success(let success):
                    _ = subscriber.receive(success.data)
                    subscriber.receive(completion: .finished)
                }
            }
            .resume()
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

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
/// A `struct` defining a new `Publisher` specific for `Response`s coming from`Request`s.
public struct RequestPublisher: Publisher {
    /// Output a `Response` item.
    public typealias Output = Response
    /// Fail to any `Error`.
    public typealias Failure = Error
    
    /// A valid `Request`.
    private var request: Request
    
    /// Init.
    /// - parameter request: A valid `Request`.
    public init(request: Request) { self.request = request }
    
    /// Receive the `Subscriber`.
    /// - parameter subscriber: A valid `Subscriber`.
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: RequestSubscription(request: request, subscriber: subscriber))
    }
}
#endif
