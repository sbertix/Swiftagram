//
//  Crypto.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 16/04/2020.
//

import Foundation

import ComposableRequest
import CryptoSwift

/// An `internal` extension for `Request` to deal with signed bodies.
internal extension Request {
    /// Sign body parameters.
    /// - parameter parameters: A valid `Dictionary` of `String`s.
    func signedBody(_ parameters: [String: Any]) -> Request {
        guard let json = try? JSONSerialization.data(withJSONObject: parameters, options: []),
            let string = String(data: json, encoding: .utf8) else {
                fatalError("`body` for `Friendship` action is not a proper JSON structure.")
        }
        guard let hash = try? HMAC(key: Constants.signatureKey, variant: .sha256)
            .authenticate(json.bytes)
            .toHexString() else {
                fatalError("Could not sign the body for `Friendship` action.")
        }
        // return.
        let encodedParameters = [
            "signed_body": "\(hash).\(string)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            "ig_sig_key_version": Constants.signatureVersion
        ]
        let data = encodedParameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)!
        return self.replacing(body: data)
    }
}
