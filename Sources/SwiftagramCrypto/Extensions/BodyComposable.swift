//
//  Crypto.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 16/04/2020.
//

import Foundation

import ComposableRequest
import SwCrypt
import Swiftagram

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
    func signing(body: Response) -> Self {
        do {
            // Encode parameters.
            guard let encoded = try? body.encode(),
                  let description = String(data: encoded, encoding: .utf8) else {
                throw SigningError.invalidRepresentation
            }
            // Compute hash.
            let hash = CC.HMAC(description.data(using: .utf8)!,
                               alg: .sha256,
                               key: Constants.signatureKey.dataFromHexadecimalString()!)
                .base64EncodedString()
            // Sign body.
            return try appending(body: [
                "signed_body": [hash, description].joined(separator: "."),
                "ig_sig_key_version": Constants.signatureVersion
            ])
        } catch {
            fatalError(["Exception raised when signing.",
                        error.localizedDescription,
                        "Please open an issue at `https://github.com/sbertix/Swiftagram/issues`."].joined(separator: " "))
        }
    }

    /// Replace body parameters with a signed version of `parameters`.
    /// - parameter parameters: A valid `Dictionary` of `String`s.
    /// - returns: An updated copy of `self`.
    func signing(body parameters: [String: Any]) -> Self {
        do {
            // Encode parameters.
            guard let encoded = try? JSONSerialization.data(withJSONObject: parameters,
                                                            options: []),
                let description = String(data: encoded, encoding: .utf8) else {
                throw SigningError.invalidRepresentation
            }
            // Compute hash.
            let hash = CC.HMAC(description.data(using: .utf8)!,
                               alg: .sha256,
                               key: Constants.signatureKey.dataFromHexadecimalString()!)
                .base64EncodedString()
            // Sign body.
            return try appending(body: [
                "signed_body": [hash, description].joined(separator: "."),
                "ig_sig_key_version": Constants.signatureVersion
            ])
        } catch {
            fatalError(["Exception raised when signing.",
                        error.localizedDescription,
                        "Please open an issue at `https://github.com/sbertix/Swiftagram/issues`."].joined(separator: " "))
        }
    }
}
