//
//  StringExtensions.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

/// `String` extension to convert `snake_case` into `camelCase`, and back.
public extension String {
    /// To `camelCase`.
    var camelCased: String {
        return split(separator: "_")
            .map(String.init)
            .enumerated()
            .map { $0.offset > 0 ? $0.element.beginningWithUppercase : $0.element.beginningWithLowercase }
            .joined()
    }

    /// To `snake-case`.
    var snakeCased: String {
        return reduce(into: "") { result, new in
            result += new.isUppercase ? "_"+String(new).lowercased() : String(new)
        }
    }

    /// Convert first letter to uppercase.
    var beginningWithUppercase: String {
        return prefix(1).uppercased()+dropFirst()
    }

    /// Convert first letter to lowercase.
    var beginningWithLowercase: String {
        return prefix(1).lowercased()+dropFirst()
    }
}
