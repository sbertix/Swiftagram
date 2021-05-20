//
//  Crypto.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 16/04/2020.
//

import Foundation

import SwCrypt
import Swiftagram

/// An `enum` listing all possible `Error`s in the signing process.
public enum SigningError: Error {
    /// Cryptography unavailable.
    case cryptographyUnavailable
    /// Invalid `JSON` representation.
    case invalidRepresentation
}

extension Int {
    /// Breadcrumb.
    var breadcrumb: String {
        let term = Int.random(in: 2...3) * 1_000 + self + Int.random(in: 15...20) * 1_000
        var textChangeEventCount = round(Double(self) / Double.random(in: 2...3))
        if textChangeEventCount == 0 { textChangeEventCount = 1 }
        let text = "\(self) \(term) \(textChangeEventCount) \(Int(Date().timeIntervalSince1970 * 1_000))"
        guard let data = text.data(using: .utf8),
              let instagramData = "iN4$aGr0m".data(using: .utf8) else {
            fatalError("Invalid breadcrumb for \(self)")
        }
        let hash = CC.HMAC(data,
                           alg: .sha256,
                           key: instagramData)
            .base64EncodedString()
        let body = data.base64EncodedString()
        return "\(hash)\n\(body)\n"
    }
}

extension Body {
    /// Sign `body` and update the request accordingly.
    ///
    /// - parameter body: A valid `Wrapper`.
    /// - returns: An updated copy of `self`.
    func signing(body: Wrapper) -> Self {
        do {
            // Encode parameters.
            guard let encoded = try? body.encode(),
                  let description = String(data: encoded, encoding: .utf8),
                  let data = description.data(using: .utf8),
                  let hex = "937463b5272b5d60e9d20f0f8d7d192193dd95095a3ad43725d494300a5ea5fc"
                    .dataFromHexadecimalString() else {
                throw SigningError.invalidRepresentation
            }
            // Compute hash.
            let hash = CC.HMAC(data,
                               alg: .sha256,
                               key: hex)
                .base64EncodedString()
            // Sign body.
            return self.body(appending: [
                "signed_body": [hash, description].joined(separator: "."),
                "ig_sig_key_version": "5"
            ])
        } catch {
            fatalError(["Exception raised when signing. \(error.localizedDescription).",
                        error.localizedDescription,
                        "Please open an issue at `https://github.com/sbertix/Swiftagram/issues`."].joined(separator: " "))
        }
    }

    /// Sign `body` and update the request accordingly.
    ///
    /// - parameter body: A valid `Wrappable`.
    /// - returns: An updated copy of `self`.
    func signing<W: Wrappable>(body: W) -> Self {
        signing(body: body.wrapped)
    }
}
