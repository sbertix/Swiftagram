//
//  URLSession.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 01/08/20.
//

import Foundation

public extension URLSession {
    /// An **Instagram**-safe `URLSession`.
    static let instagram: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 1
        return .init(configuration: configuration)
    }()

    /// An epehemeral `URLSession`.
    static let ephemeral: URLSession = {
        .init(configuration: URLSessionConfiguration.ephemeral)
    }()
}
