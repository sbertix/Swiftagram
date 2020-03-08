//
//  EndpointMethod.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

public extension Endpoint {
    /// An `enum` holding reference to a `Endpoint`'s `Method`.
    enum Method {
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
}
