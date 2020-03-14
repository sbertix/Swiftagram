//
//  Paginatable.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 14/03/2020.
//

import Foundation

/// A `protocol` defining an expected `Response` type, ready for pagination.
public protocol Paginatable: Expecting {
    /// The originating `Expecting` type.
    associatedtype Originating: Singular

    /// The originating `Expecting` value.
    var paginatable: Originating { get set }

    /// The `name` of the `URLQueryItem` used for paginating.
    var key: String { get set }

    /// The inital `value` of the `URLQueryItem` used for paginating.
    var initial: String? { get set }

    /// The next `value` of the `URLQueryItem` user for paginating, based on the last `Response`.
    var next: (Result<Response, Error>) -> String? { get set }
}

/// Defaults extensions for `Singular`.
public extension Singular {
    /// Wrap in `Pagination`.
    /// - parameters:
    ///     - key: The `name` of the `URLQueryItem` used for paginating. Defaults to `max_id`.
    ///     - initial: The inital `value` of the `URLQueryItem` used for paginating. Defaults to `nil`.
    ///     - next: The next `value` of the `URLQueryItem` user for paginating, based on the last `Response`.
    /// - returns: A `Pagination` item.
    func paginating(key: String = "max_id",
                    initial: String? = nil,
                    next: @escaping (Result<Response, Error>) -> String?) -> Paginated<Self, Response> {
        return .init(paginatable: self, key: key, initial: initial, next: next)
    }
}

/// Defaults extensions for `Singular` expecting `Response`.
public extension Singular where Response == Swiftagram.Response {
    /// Wrap in `Pagination`.
    /// - parameters:
    ///     - key: The `name` of the `URLQueryItem` used for paginating. Defaults to `max_id`.
    ///     - initial: The inital `value` of the `URLQueryItem` used for paginating. Defaults to `nil`.
    ///     - next: The next `value` of the `URLQueryItem` user for paginating, based on the last `Response`. Defaults to `.nextMaxId.string()`.
    /// - returns: A `Pagination` item.
    func paginating(key: String = "max_id",
                    initial: String? = nil,
                    next: @escaping (Result<Response, Error>) -> String? = { try? $0.get().nextMaxId.string() }) -> Paginated<Self, Response> {
        return .init(paginatable: self, key: key, initial: initial, next: next)
    }
}

/// Default extensions for `Paginatable`.
public extension Paginatable {
    /// Set `key`.
    /// - parameter key: A valid `String`.
    /// - returns: A modified copy of `self`.
    func key(_ key: String) -> Self {
        return copy(self) { $0.key = key }
    }

    /// Set `initial`.
    /// - parameter initial: A valid optional `String`.
    /// - returns: A modified copy of `self`.
    func initial(_ initial: String?) -> Self {
        return copy(self) { $0.initial = initial }
    }

    /// Wrap a new `Expected` value.
    /// - parameters:
    ///     - response: A concrete `DataMappable` type.
    ///     - next: The next `value` of the `URLQueryItem` user for paginating, based on the last `Response`.
    /// - returns: A modified copy of `self`.
    func expecting<Response: DataMappable>(_ response: Response.Type,
                                           next: @escaping (Result<Response, Error>) -> String?) -> Paginated<Originating, Response> {
        return .init(paginatable: paginatable,
                     key: key,
                     initial: initial,
                     next: next)
    }

    /// Unwrap `Originating`.
    /// - returns: An `Expected` value.
    func once() -> Expected<Originating, Response> {
        return .init(expecting: paginatable)
    }
}
