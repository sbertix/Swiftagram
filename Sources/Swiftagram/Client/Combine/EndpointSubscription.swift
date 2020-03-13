//
//  EndpointSubscription.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 11/03/2020.
//

#if canImport(Combine)
import Combine
import Foundation

/// A `class` defining a new `Subscription` specific for `Response`s coming from `Endpoint` requests.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class EndpointSubscription<Subscriber: Combine.Subscriber>: Subscription
where Subscriber.Input: DataMappable, Subscriber.Failure == Error {
    /// A `Requester.Task`.
    private var task: Requester.Task?
    /// A `Subscriber`.
    private var subscriber: Subscriber?

    // MARK: Lifecycle
    /// Init.
    /// - parameters:
    ///     - request: A valid `Endpoint`.
    ///     - subscriber: The `Subscriber`.
    public init<Request: Composable & Requestable>(request: Request, subscriber: Subscriber) where Subscriber.Input == Request.Response {
        self.subscriber = subscriber
        self.task = request.expecting(Request.Response.self).task {
            switch $0 {
            case .failure(let error): subscriber.receive(completion: .failure(error))
            case .success(let success):
                _ = subscriber.receive(success)
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
#endif
