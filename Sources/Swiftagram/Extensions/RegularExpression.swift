//
//  RegularExpression.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 04/01/2020.
//

import Foundation

/// A `struct` defining a `RegexMatch`.
public struct RegexMatch {
    /// The actual match.
    public let match: String
    /// The range in the original string.
    public let range: Range<String.Index>
}

/// A `String` extension for simplifying regular expression.
public extension String {
    /// Regular expression matches of `pattern` in `self`.
    /// - parameter pattern: The regular expression pattern.
    /// - parameter range: The `Range` when searching for matches.  `nil` searches the entire string. Defaults to `nil`.
    /// - returns: An `Array` of `RegexMatch`. Or `nil` if the `pattern` was invalid..
    func matches(for pattern: String, in range: Range<String.Index>? = nil) -> [RegexMatch]? {
        guard let expression = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        return expression.matches(in: self, options: [], range: NSRange(range ?? startIndex..<endIndex, in: self))
            .compactMap {
                Range($0.range, in: self).flatMap { RegexMatch(match: String(self[$0]), range: $0) }
            }
    }
}
