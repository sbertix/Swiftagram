//
//  Endpoint.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

/// A `struct` defining all possible `Endpoint`s.
@dynamicMemberLookup
public struct Endpoint: Hashable {
    /// A `[String]` composed of all path components.
    internal var components: [String]
    /// A `[String: String]` composed of all key-values to set as body. Defaults to `[:]`.
    internal var body: [String: String] = [:]
    /// A `[String: String]` composed of all query components. Defaults to `[:]`
    internal var queries: [String: String] = [:]
    /// A `[String: String]` composed of all custom header fields. Defaults to `[:]`.
    internal var headerFields: [String: String] = [:]
    /// The `Method`. Defaults to `default`.
    internal var method: Method = .default

    // MARK: Lifecycle
    /// Init.
    /// - parameters:
    ///     - components: A `Collection` of `String`s, forming a valid `https` address, when joined together using `/`.
    ///     - headerFields. A `Dictionary` of `(key: String, value: String)`, forming valid header fields.
    public init(components: [String]) { self.components = components }

    /// Init.
    /// - parameter url: A `URL`.
    public init(url: URL) {
        self.components = [url.absoluteString.trimmingCharacters(in: .init(charactersIn: "/"))]
    }

    // MARK: Accessories
    /// Compute the `URLRequest`.
    public func request() -> URLRequest? {
        // prepare the main components.
        var components = URLComponents(string: self.components.joined(separator: "/")+"/")
        components?.queryItems = queries.isEmpty ? nil : queries.map { URLQueryItem(name: $0.key, value: $0.value) }
        let body = !self.body.isEmpty
            ? self.body.map {
                [$0.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                 $0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)]
                    .compactMap { $0 }
                    .joined(separator: "=")
            }.joined(separator: "&").data(using: .utf8)
            : nil
        // prepare the request.
        guard var request = components?.url.flatMap({
            URLRequest(url: $0,
                       cachePolicy: .useProtocolCachePolicy,
                       timeoutInterval: 10)
        }) else { return nil }
        request.allHTTPHeaderFields = headerFields
        request.httpBody = body
        request.httpMethod = body.map(method.resolve)
        return request
    }

    // MARK: Composition
    /// An `Endpoint` pointing to `api/v1`.
    public static var version1: Endpoint { return .init(components: ["https://i.instagram.com/api/v1"]) }
    /// An `Endpoint`pointing to `api/v2`.
    public static var version2: Endpoint { return .init(components: ["https://i.instagram.com/api/v2"]) }
    /// An `Endpoint` pointing to the Instagram homepage.
    public static var generic: Endpoint { return .init(components: ["https://www.instagram.com"]) }

    /// Append `item`.
    public func wrap<Item>(_ item: Item) -> Endpoint where Item: LosslessStringConvertible {
        var copy = self
        copy.components.append(String(item)
            .trimmingCharacters(in: .init(charactersIn: "/"))
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")
        return copy
    }

    /// Append `item`.
    public func wrap<Item>(_ item: Item) -> Endpoint where Item: CustomStringConvertible {
        var copy = self
        copy.components.append(item.description
            .trimmingCharacters(in: .init(charactersIn: "/"))
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")
        return copy
    }

    /// Append `component`.
    public subscript(dynamicMember component: String) -> Endpoint {
        var copy = self
        copy.components.append(component
            .trimmingCharacters(in: .init(charactersIn: "/"))
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")
        return copy
    }

    /// Append to `body`.
    public func body(key: String, value: String?) -> Endpoint {
        return body([key: value])
    }

    /// Append `body`. Empty `self.body` if `nil`.
    public func body(_ body: [String: String?]?) -> Endpoint {
        var copy = self
        if body == nil {
            copy.body = [:]
        } else {
            body?.forEach { copy.body[$0.key] = $0.value }
        }
        return copy
    }

    /// Append to `queries`.
    public func query(key: String, value: String?) -> Endpoint {
        return query([key: value])
    }

    /// Append `queries`. Empty `self.queries` if `nil`.
    public func query(_ queries: [String: String?]?) -> Endpoint {
        var copy = self
        if queries == nil {
            copy.queries = [:]
        } else {
            queries?.forEach { copy.queries[$0.key] = $0.value }
        }
        return copy
    }

    /// Append default `headerFields`.
    public func defaultHeaderFields() -> Endpoint {
        return self.headerFields(
            [Headers.acceptLanguageKey: Headers.acceptLanguageValue,
             Headers.contentTypeKey: Headers.contentTypeApplicationFormValue,
             Headers.igCapabilitiesKey: Headers.igCapabilitiesValue,
             Headers.igConnectionTypeKey: Headers.igConnectionTypeValue,
             Headers.userAgentKey: Headers.userAgentValue]
        )
    }

    /// Append `headerFields`. Empty `self.headerFields` if `nil`.
    public func headerFields(_ headerFields: [String: String]?) -> Endpoint {
        var copy = self
        copy.headerFields = headerFields.flatMap { copy.headerFields.merging($0) { _, rhs in rhs }} ?? [:]
        return copy
    }

    /// Append `headerFields` for `secret`.
    /// - parameter secret: A valid `Secret`.
    public func authenticating(with secret: Secret) -> Endpoint {
        return headerFields(secret.headerFields)
    }

    /// Set `method`.
    /// - parameter method: A `Method` value.
    public func method(_ method: Method) -> Endpoint {
        var copy = self
        copy.method = method
        return copy
    }
}
