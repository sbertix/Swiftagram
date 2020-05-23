//
//  JSONSerialization.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 23/05/2020.
//

import Foundation

extension JSONSerialization {
    /// Stringify `value`.
    static func stringify(_ value: Any) -> String {
        return String(data: (try? JSONSerialization.data(withJSONObject: value, options: [])) ?? .init(),
                      encoding: .utf8) ?? ""
    }
}
