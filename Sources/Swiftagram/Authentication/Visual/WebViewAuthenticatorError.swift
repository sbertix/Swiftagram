//
//  WebViewAuthenticatorError.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 22/07/2020.
//

import Foundation

/// An `enum` listing all possible `Error`s in a visual based authentication process.
public enum WebViewAuthenticatorError: Swift.Error {
    /// Invalid cookies.
    case invalidCookies
    /// Invalid URL.
    case invalidURL
}
