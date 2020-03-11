//
//  EndpointRequests.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 11/03/2020.
//

import Foundation

public extension Endpoint {
    // MARK: Once
    /// Prepare the `Requester.Task`.
    /// - parameters:
    ///     - response: A `DataMappable` type.
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onComplete: A block accepting a `DataMappable`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func task<Response>(_ response: Response.Type,
                        by requester: Requester = .default,
                        onComplete: @escaping (Requester.Task.Result<Response>) -> Void) -> Requester.Task where Response: DataMappable {
        return Requester.Task(endpoint: self,
                              requester: requester) {
                                onComplete($0.map { (Response.process(data: $0.data), $0.response) })
                                return nil
        }
    }
    
    /// Prepare the `Requester.Task`.
    /// - parameters:
    ///     - responser: A `Decodable` type.
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onComplete: A block accepting a `DataMappable`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func task<Response>(decodable response: Response.Type,
                        by requester: Requester = .default,
                        onComplete: @escaping (Requester.Task.Result<Response>) -> Void) -> Requester.Task where Response: Decodable {
        return Requester.Task(endpoint: self,
                              requester: requester) {
                                onComplete($0.flatMap { result in
                                    let decoder = JSONDecoder()
                                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                                    return Result { (try decoder.decode(Response.self, from: result.data), response: result.response) }
                                })
                                return nil
        }
    }
    
    /// Prepare the `Requester.Task`.
    /// - parameters:
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onComplete: A block accepting a `DataMappable`.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func task(by requester: Requester = .default,
              onComplete: @escaping (Requester.Task.Result<Response>) -> Void) -> Requester.Task {
        return task(Response.self, onComplete: onComplete)
    }
    
    // MARK: Cycle
    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - response: A `DataMappable` type.
    ///     - key: A `String` representing the url query item name. Defaults to `max_id`.
    ///     - initial: An optional `String` representing the url query item value for the first request. Defaults to `nil`.
    ///     - next: A block accepting a `Response` and returning the query item value for the next page. `nil` to stop paginating.
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onChange: A block accepting a `DataMappable` and returning the next max id value.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func cycleTask<Response>(_ response: Response.Type,
                             key: String = "max_id",
                             initial: String? = nil,
                             next: @escaping (Requester.Task.Result<Response>) -> String?,
                             by requester: Requester = .default,
                             onChange: @escaping (Requester.Task.Result<Response>) -> Void) -> Requester.Task where Response: DataMappable {
        return Requester.Task(endpoint: self,
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = $0.map { (data: Response.process(data: $0.data), response: $0.response) }
                                var nextEndpoint: Endpoint?
                                if let nextValue = next(mapped) {
                                    nextEndpoint = self.query(key: key, value: nextValue)
                                }
                                // Notify completion.
                                onChange(mapped)
                                // Return the new endpoint.
                                return nextEndpoint
        }
    }
    
    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - response: A `Decodable` type.
    ///     - key: A `String` representing the url query item name. Defaults to `max_id`.
    ///     - initial: An optional `String` representing the url query item value for the first request. Defaults to `nil`.
    ///     - next: A block accepting a `Response` and returning the query item value for the next page. `nil` to stop paginating.
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onChange: A block accepting a `DataMappable` and returning the next max id value.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func cycleTask<Response>(decodable response: Response.Type,
                             key: String = "max_id",
                             initial: String? = nil,
                             next: @escaping (Requester.Task.Result<Response>) -> String?,
                             by requester: Requester = .default,
                             onChange: @escaping (Requester.Task.Result<Response>) -> Void) -> Requester.Task where Response: Decodable {
        return Requester.Task(endpoint: self,
                              requester: requester) {
                                // Get the next `Endpoint`.
                                let mapped = $0.flatMap { result -> Requester.Task.Result<Response> in
                                    let decoder = JSONDecoder()
                                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                                    return Result { try (data: decoder.decode(Response.self, from: result.data), response: result.response) }
                                }
                                var nextEndpoint: Endpoint?
                                if let nextValue = next(mapped) {
                                    nextEndpoint = self.query(key: key, value: nextValue)
                                }
                                // Notify completion.
                                onChange(mapped)
                                // Return the new endpoint.
                                return nextEndpoint
        }
    }
    
    /// Prepare a pagination `Requester.Task`.
    /// - parameters:
    ///     - key: A `String` representing the url query item name. Defaults to `max_id`.
    ///     - initial: An optional `String` representing the url query item value for the first request. Defaults to `nil`.
    ///     - next: A block accepting a `Response` and returning the query item value for the next page. `nil` to stop paginating.
    ///     - requester:  A `Requester`. Defaults to `.default`.
    ///     - onChange: A block accepting a `DataMappable` and returning the next max id value.
    /// - returns: A `Requester.Task`. You need to `resume()` it for it to start.
    func cycleTask(key: String = "max_id",
                   initial: String? = nil,
                   next: @escaping (Requester.Task.Result<Response>) -> String?,
                   by requester: Requester = .default,
                   onChange: @escaping (Requester.Task.Result<Response>) -> Void) -> Requester.Task {
        return cycleTask(Response.self, key: key, initial: initial, next: next, by: requester, onChange: onChange)
    }
}
