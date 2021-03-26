//
//  Parent.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 25/03/21.
//

import Foundation

/// A `protocol` defining an instance capable of
/// fetching `Request`s.
protocol Parent {
    /// Compose a new request.
    ///
    /// - parameters:
    ///     - path: A valid `Request`.
    ///     - transformer: A valid mapper.
    /// - returns: Some `Endpoint.Disposable`.
    func disposable<W: Wrapped>(at path: Request,
                                _ transformer: @escaping (Secret, SessionProviderInput, Request) -> Request) -> Endpoint.Disposable<W, Error>

    /// Compose a new request.
    ///
    /// - parameters:
    ///     - path: A valid `Request`.
    ///     - iterator: A valid iterator.
    ///     - transformer: A valid mapper.
    /// - returns: Some `Endpoint.Paginated`.
    func paginated<O, W>(at path: Request,
                         iterating iterator: @escaping (O, AnyPublisher<W, Error>) -> Pager<O, Publishers.Output<AnyPublisher<W, Error>>>.Iteration,
                         _ transformer: @escaping (Secret, SessionProviderInput, O, Request) -> Request) -> Endpoint.Paginated<W, O, Error>
        where W: Wrapped
}

extension Parent {
    /// Compose a new request.
    ///
    /// - parameters:
    ///     - path: A valid `Request`.
    ///     - transformer: A valid mapper. Defaults to the input request.
    /// - returns: Some `Endpoint.Disposable`.
    func disposable<W>(at path: Request,
                       _ transformer: @escaping (Secret, SessionProviderInput, Request) -> Request = { $2 })
        -> Endpoint.Disposable<W, Error> where W: Wrapped {
            .init { secret, session in
                Deferred {
                    transformer(secret, session, path)
                        .appendingDefaultHeader()
                        .header(appending: secret.header)
                        .publish(with: session)
                        .map(\.data)
                        .wrap()
                        .map(W.init)
                }
                .eraseToAnyPublisher()
            }
    }

    /// Compose a new request.
    ///
    /// - parameters:
    ///     - path: A valid `Request`.
    ///     - iterator: A valid iterator.
    ///     - transformer: A valid mapper.
    /// - returns: Some `Endpoint.Paginated`.
    func paginated<O, W>(at path: Request,
                         iterating iterator: @escaping (O, AnyPublisher<W, Error>) -> Pager<O, Publishers.Output<AnyPublisher<W, Error>>>.Iteration,
                         _ transformer: @escaping (Secret, SessionProviderInput, O, Request) -> Request) -> Endpoint.Paginated<W, O, Error>
        where W: Wrapped {
            .init { secret, session, pages in
                Deferred {
                    Pager(pages) {
                        iterator(
                            $0,
                            transformer(secret, session, $0, path)
                                .appendingDefaultHeader()
                                .header(appending: secret.header)
                                .publish(with: session)
                                .map(\.data)
                                .wrap()
                                .map(W.init)
                                .eraseToAnyPublisher()
                        )
                    }
                }
                .eraseToAnyPublisher()
            }
    }

    /// Compose a new request.
    ///
    /// - parameters:
    ///     - path: A valid `Request`.
    ///     - iterator: A valid iterator.
    ///     - transformer: A valid mapper.
    /// - returns: Some `Endpoint.Paginated`.
    func paginated<W>(at path: Request,
                      _ transformer: @escaping (Secret, SessionProviderInput, W.Offset, Request) -> Request) -> Endpoint.Paginated<W, W.Offset, Error>
        where W: Wrapped, W: Paginatable, W.Offset: Equatable {
            paginated(at: path,
                      iterating: { $1.iterateFirst(stoppingAt: $0) },
                      transformer)
    }
}
