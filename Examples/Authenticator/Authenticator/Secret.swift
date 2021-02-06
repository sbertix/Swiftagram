//
//  Secret.swift
//  Authenticator
//
//  Created by Stefano Bertagno on 07/02/21.
//

import Foundation

import Swiftagram

extension Secret {
    /// Compute the token.
    var token: String? { try? JSONEncoder().encode(self).base64EncodedString() }
}
