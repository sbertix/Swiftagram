//
//  ComposableRequest.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 13/03/2020.
//

import Foundation

/// A `struct` representing a composable `URLRequest`.
@dynamicMemberLookup
public struct ComposableRequest: Hashable, Requestable {
    /// `ComposableRequest` defaults to `Response`.
    public typealias Response = Swiftagram.Response

    /// An `enum` representing a `URLRequest` possible `httpBody`-s.
    public enum Body: Hashable {
        /// A `Dictionary` of `String`s.
        case parameters([String: String])
        /// A `Data` value.
        case data(Data)

        /// Encode to `Data`.
        internal var data: Data? {
            switch self {
            case .data(let data): return data
            case .parameters(let parameters):
                return parameters.map { [$0.key, "=", $0.value].joined() }
                    .joined(separator: "&")
                    .data(using: .utf8)
            }
        }
    }

    /// An `enum` representing a `URLRequest` allowed `httpMethod`s.
    public enum Method: Hashable {
        /// `GET` when no `body` is set, `POST` otherwise.
        case `default`
        /// `GET`.
        case get
        /// `POST`
        case post

        /// A `String` based method, according to `.httpBody`.
        internal func resolve(using body: Data?) -> String {
            switch self {
            case .get: return "GET"
            case .post: return "POST"
            case .default:
                return body?.isEmpty == false
                    ? "POST"
                    : "GET"
            }
        }
    }

    /// A valid `URLComponents` item.
    public var components: URLComponents
    /// A valid `Method`.
    public var method: Method
    /// A valid `Body`.
    public var body: Body?
    /// A valid `Dictionary` of `String`s referencing the request header fields.
    public var headerFields: [String: String]

    // MARK: Lifecycle
    /// Init.
    /// - parameters:
    ///     - url: A valid `URL`.
    ///     - method: A valid `Method`. Defaults to `.default`.
    ///     - body: A valid optional `Body`. Defaults to `nil`.
    ///     - headerFields: A valid `Dictionary` of `String`s. Defaults to `[:]`.
    public init(url: URL, method: Method = .default, body: Body? = nil, headerFields: [String: String] = [:]) {
        self.components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        self.method = method
        self.body = body
        self.headerFields = headerFields
    }
}

// MARK: Composable
/// `Composable` conformacies.
extension ComposableRequest: Composable {
    /// Compute the `URLRequest`.
    /// - returns: An optional `URLRequest`.
    public func request() -> URLRequest? {
        return components.url.flatMap {
            var request = URLRequest(url: $0)
            request.httpBody = body?.data
            request.httpMethod = method.resolve(using: request.httpBody)
            request.allHTTPHeaderFields = headerFields
            return request
        }
    }

    /// Append `pathComponent`.
    /// - parameter pathComponent: A `String` representing a path component.
    public func append(_ pathComponent: String) -> ComposableRequest {
        return copy(self) {
            $0.components = $0.components.url
                .flatMap {
                    $0.appendingPathComponent(pathComponent.trimmingCharacters(in: .init(charactersIn: "/"))+"/")
                }
                .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) } ?? $0.components
        }
    }

    /// Append to `queryItems`. Empty `queryItems` if `nil`.
    /// - parameter method: A `ComposableRequest.Method` value.
    public func query(_ items: [String: String?]?) -> ComposableRequest {
        return copy(self) {
            guard let items = items else {
                $0.components.queryItems = nil
                return
            }
            var dictionary = Dictionary(uniqueKeysWithValues:
                $0.components.queryItems?.compactMap { item in
                    item.value.flatMap { (item.name, $0) }
                    } ?? []
            )
            items.forEach { dictionary[$0.key] = $0.value }
            $0.components.queryItems = dictionary.isEmpty
                ? nil
                : dictionary.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
    }

    /// Set `method`.
    /// - parameter method: A `ComposableRequest.Method` value.
    public func method(_ method: ComposableRequest.Method) -> ComposableRequest {
        return copy(self) { $0.method = method }
    }

    /// Set `body`.
    /// - parameter body: A valid `ComposableRequest.Body`.
    public func body(_ body: ComposableRequest.Body) -> ComposableRequest {
        return copy(self) { $0.body = body }
    }

    /// Append to `ComposableRequest.Body.parameters`. Empty `body` if `nil`.
    /// - parameter parameters: An optional `Dictionary` of  option`String`s.
    public func body(_ parameters: [String: String?]?) -> ComposableRequest {
        return copy(self) {
            guard let body = $0.body, case .parameters(var dictionary) = body else {
                $0.body = parameters.flatMap { .parameters($0.compactMapValues { $0 }) }
                return
            }
            parameters?.forEach { dictionary[$0.key] = $0.value }
            $0.body = dictionary.isEmpty ? nil : .parameters(dictionary)
        }
    }

    /// Append to `headerFields`. Empty `headerFields` if `nil`.
    /// - parameter fields: An optional `Dictionary` of  option`String`s.
    public func header(_ fields: [String: String?]?) -> ComposableRequest {
        return copy(self) {
            var dictionary = $0.headerFields
            fields?.forEach { dictionary[$0.key] = $0.value }
            $0.headerFields = dictionary
        }
    }
}
