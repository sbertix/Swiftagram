//
//  AuthenticatorError.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

/// An `enum` describing `Authentictor` specific `Error`s.
public enum AuthenticatorError: Error {
    /// Checkpoint encountered.
    case checkpoint(Checkpoint?)
    /// Invalid code.
    case invalidCode
    /// Invalid cookies.
    case invalidCookies
    /// Invalid password.
    case invalidPassword
    /// Invalid response.
    case invalidResponse
    /// Invalid URL.
    case invalidURL
    /// Invalid username.
    case invalidUsername
    /// Try again immediately.
    case retry
    /// Two factor challenge encountered
    case twoFactor(TwoFactor?)
}
