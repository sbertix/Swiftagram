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

/// An `internal` extension to computer the breadcrumb.
internal extension Int {
    /// Breadcrumb.
    var breadcrumb: String {
        let term = Int.random(in: 2...3)*1000+self+Int.random(in: 15...20)*1000
        var textChangeEventCount = round(Double(self)/Double.random(in: 2...3))
        if textChangeEventCount == 0 { textChangeEventCount = 1 }
        let data = "\(self) \(term) \(textChangeEventCount) \(Int(Date().timeIntervalSince1970*1000))"
        let hash = CC.HMAC(data.data(using: .utf8)!,
                           alg: .sha256,
                           key: Constants.breadcrumbKey.data(using: .utf8)!)
            .base64EncodedString()
        let body = data.data(using: .utf8)!.base64EncodedString()
        return "\(hash)\n\(body)\n"
    }
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
            fatalError(["Exception raised when signing. \(error.localizedDescription).",
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
