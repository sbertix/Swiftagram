//
//  PaginatableSubscription.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 11/03/2020.
//

#if canImport(Combine)
import Combine
import Foundation

/// A `class` defining a new `Subscription` specific for `Response`s coming from `Endpoint` requests.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class PaginatableSubscription<Subscriber: Combine.Subscriber>: Subscription
where Subscriber.Input: DataMappable, Subscriber.Failure == Error {
    /// A `Subscriber`.
    private var subscriber: Subscriber?
    /// A `Requester.Task`.
    private var task: Requester.Task? {
        didSet {
            guard task?.identifier != oldValue?.identifier else { return }
            self.count = 0
            self.max = .max
        }
    }
    /// The current fetched count.
    private var count: Int = 0
    /// The maximum amount to fetch.
    private var max: Int = .max

    // MARK: Lifecycle
    /// Deinit.
    deinit {
        task?.cancel()
    }
    
    /// Init.
    /// - parameters:
    ///     - request: A valid `Endpoint`.
    ///     - subscriber: The `Subscriber`.
    public init<Request: Composable & Paginatable & Requestable>(request: Request,
                                                                 requester: Requester?,
                                                                 subscriber: Subscriber) where Subscriber.Input == Request.Response {
        self.subscriber = subscriber
        self.task = request.cycleTask(by: requester ?? .default,
                                      onComplete: { [weak self] in
                                        guard let self = self, $0 < self.max else { return }
                                        subscriber.receive(completion: .finished)
        }) { [weak self] in
            guard let self = self else { return subscriber.receive(completion: .finished) }
            switch $0 {
            case .failure(let error): subscriber.receive(completion: .failure(error))
            case .success(let success):
                _ = subscriber.receive(success)
                // Check for `count` before completing.
                self.count += 1
                guard self.count < self.max else {
                    self.task?.cancel()
                    return subscriber.receive(completion: .finished)
                }
            }
        }
        //self.task?.resume()
    }

    // MARK: Subscription
    /// Request. The default implementation does nothing.
    public func request(_ demand: Subscribers.Demand) {
        guard demand > 0 else {
            subscriber?.receive(completion: .finished)
            return
        }
        self.max = demand.max ?? .max
        self.task?.resume()
    }

    /// Cancel.
    public func cancel() {
        self.task = nil
        self.subscriber = nil
    }
}
#endif
