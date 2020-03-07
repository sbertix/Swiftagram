//
//  Endpoint.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 06/03/2020.
//

import Foundation

@dynamicMemberLookup
/// A `struct` defining all possible `Endpoint`s.
public struct Endpoint: Hashable {
    /// An `enum` holding reference to a `Request`'s `Method`.
    public enum Method {
        /// Automatic. `.post` when a body is set, `.get` otherwise.
        case `default`
        /// GET.
        case get
        /// POST.
        case post

        /// Resolve starting from a given `body`.
        /// - parameter body: An optional `Data` holding the body of the request.
        internal func resolve(using body: Data?) -> String {
            switch self {
            case .default: return body == nil ? "GET" : "POST"
            case .get: return "GET"
            case .post: return "POST"
            }
        }
    }

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

    /// Compute the `URLRequest`.
    public var request: URLRequest? {
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

    // MARK: Lifecycle
    /// Init.
    /// - parameter components: A `Collection` of `String`s, forming a valid `https` address, when joined together using `/`.
    /// - parameter headerFields. A `Dictionary` of `(key: String, value: String)`, forming valid header fields.
    public init(components: [String]) { self.components = components }

    /// Init.
    /// - parameter url: A `URL`.
    public init(url: URL) {
        self.components = [url.absoluteString.trimmingCharacters(in: .init(charactersIn: "/"))]
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
        var copy = self
        copy.body[key] = value
        return copy
    }
    /// Append `body`. Empty `self.body` if `nil`.
    public func body(_ body: [String: String]?) -> Endpoint {
        var copy = self
        copy.body = body.flatMap { copy.body.merging($0) { _, rhs in rhs }} ?? [:]
        return copy
    }

    /// Append to `queries`.
    public func query(key: String, value: String?) -> Endpoint {
        var copy = self
        copy.queries[key] = value
        return copy
    }
    /// Append `queries`. Empty `self.queries` if `nil`.
    public func query(_ queries: [String: String]?) -> Endpoint {
        var copy = self
        copy.queries = queries.flatMap { copy.queries.merging($0) { _, rhs in rhs }} ?? [:]
        return copy
    }

    /// Append default `headerFields`.
    public var defaultHeaderFields: Endpoint {
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

    /// Set `method`.
    /// - parameter method: A `Method` value.
    public func method(_ method: Method) -> Self {
        var copy = self
        copy.method = method
        return copy
    }
}
