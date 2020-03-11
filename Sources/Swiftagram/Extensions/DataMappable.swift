//
//  DataMappable.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 11/03/2020.
//

import Foundation

/// A `protocol` describing an item describable from `Data`.
public protocol DataMappable {
    /// Accept `data` and returns an element of `Self`.
    /// - parameter data: Some `Data`.
    static func process(data: Data) -> Self
}

extension Response: DataMappable {
    /// Accept `data` and returns an element of `Response`.
    /// - parameter data: Some `Data`.
    public static func process(data: Data) -> Response {
        return (try? Response(data: data)) ?? .none
    }
}

extension String: DataMappable {
    /// Accept `data` and returns an element of `String`.
    /// - parameter data: Some `Data`.
    public static func process(data: Data) -> String {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

extension Data: DataMappable {
    /// Accept `data` and returns it.
    /// - parameter data: Some `Data`.
    public static func process(data: Data) -> Data {
        return data
    }
}
