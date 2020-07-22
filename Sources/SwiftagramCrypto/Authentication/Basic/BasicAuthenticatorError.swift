//
//  BasicAuthenticatorError.swift
//  SwiftagramCrypto
//
//  Created by Stefano Bertagno on 22/07/2020.
//

import Foundation

/// An `enum` describing all possible `Error`s in the authentication process.
public enum BasicAuthenticatorError: Swift.Error {
    /// Invalid cookies.
    case invalidCookies
    /// Invalid username.
    case invalidUsername
    /// Invalid password.
    case invalidPassword
    /// Invalid response.
    case invalidResponse
    /// Custom error.
    case custom(String)
    
    /// Two factor required.
    case twoFactor(TwoFactor)
    /// Invalid two factor code.
    case invalidCode
}
