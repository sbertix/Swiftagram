//
//  Crypto.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 16/04/2020.
//

import Foundation

import ComposableRequest
import SwCrypt

/// An `enum` representing  signing-related `Error`s.
public enum SigningError: Error {
    /// Cryptography unavailable.
    case cryptographyUnavailable
    /// Invalid `JSON` representation.
    case invalidRepresentation
}

/// An `internal` extension for `Request` to deal with signed bodies.
internal extension BodyComposable where Self: BodyParsable {
    /// Replace body parameters with a signed version of `parameters`.
    /// - parameter parameters: A valid `Dictionary` of `String`s.
    /// - returns: An updated copy of `self`.
    func signing(body parameters: [String: Any]) -> Self {
        do {
            guard CC.hmacAvailable() else { throw SigningError.cryptographyUnavailable }
            // Encode parameters.
            let encodedParameters = try Response(parameters).encode()
            guard let parametersDescription = String(data: encodedParameters, encoding: .utf8) else {
                throw SigningError.invalidRepresentation
            }
            // Compute hash.
            let hash = CC.HMAC(encodedParameters, alg: .sha256, key: Constants.signatureKey.dataFromHexadecimalString()!)
                .hexadecimalString()
            // Sign body.
            return try appending(body: [
                "signed_body": [hash, parametersDescription].joined(separator: "."),
                "ig_sig_key_version": Constants.signatureVersion
            ])
        } catch {
            fatalError("Exception raised when signing. "+error.localizedDescription)
        }
    }
}
