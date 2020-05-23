//
//  Crypto.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 16/04/2020.
//

import Foundation

import ComposableRequest
import SwCrypt

/// An `internal` extension for `Request` to deal with signed bodies.
internal extension BodyComposable {
    /// Replace body parameters with a signed version of `parameters`.
    /// - parameter parameters: A valid `Dictionary` of `String`s.
    /// - returns: An updated copy of `self`.
    func signing(body parameters: [String: Any]) -> Self {
        guard CC.hmacAvailable() else {
            fatalError("Cryptography unavailable.")
        }
        guard let json = try? JSONSerialization.data(withJSONObject: parameters, options: []),
            let string = String(data: json, encoding: .utf8) else {
                fatalError("`body` for `Friendship` action is not a proper JSON structure.")
        }
        let hash = CC.HMAC(json, alg: .sha256, key: Constants.signatureKey.dataFromHexadecimalString()!)
            .hexadecimalString()
        // return.
        let encodedParameters = [
            "signed_body": "\(hash).\(string)",
            "ig_sig_key_version": Constants.signatureVersion
        ]
        return replacing(body: encodedParameters)
    }
}
