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
    /// Sign body parameters.
    /// - parameter parameters: A valid `Dictionary` of `String`s.
    func signing(body parameters: [String: Any]) -> Self {
        guard let json = try? JSONSerialization.data(withJSONObject: parameters, options: []),
            let string = String(data: json, encoding: .utf8) else {
                fatalError("`body` for `Friendship` action is not a proper JSON structure.")
        }
        let hash = CC.HMAC(json, alg: .sha256, key: Constants.signatureKey.dataFromHexadecimalString()!)
            .hexadecimalString()
        // return.
        let encodedParameters = [
            "signed_body": "\(hash).\(string)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            "ig_sig_key_version": Constants.signatureVersion
        ]
        let data = encodedParameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)!
        return self.replacing(body: data)
    }
}
