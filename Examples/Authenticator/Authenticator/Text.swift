//
//  Text.swift
//  Authenticator
//
//  Created by Stefano Bertagno on 07/02/21.
//

import SwiftUI

extension Text {
    /// Combine a collection of texts.
    ///
    /// - parameters: A collection of `Text`s.
    /// - returns: A valid `Text`.
    static func combine(_ texts: Text...) -> Text {
        combine(texts)
    }

    /// Combine a collection of texts.
    ///
    /// - parameters: A collection of `Text`s.
    /// - returns: A valid `Text`.
    static func combine(_ texts: [Text]) -> Text {
        guard let first = texts.first else {
            fatalError("`texts` should not be empty")
        }
        return texts.dropFirst().reduce(first) { $0+$1 }
    }
}
