//
//  Checkpoint.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import Foundation

/// A `class` holding reference to a `Checkpoint`.
public final class Checkpoint {
    /// Any `Storage`.
    internal let storage: Storage
    /// A `URL` originating the `Checkpoint`.
    internal let url: URL
    /// A `HTTPCookie` for `csrftoken`.
    internal let crossSiteRequestForgery: HTTPCookie
    /// A `Set` of `Verification` representing available methods.
    public let availableVerification: Set<Verification>
    /// A block providing an `Authentication.Response`.
    internal let onChange: (Result<Authentication.Response, Swift.Error>) -> Void
    
    // MARK: Lifecycle
    /// Init.
    internal init<Storage: Swiftagram.Storage>(storage: Storage,
                                               url: URL,
                                               crossSiteRequestForgery: HTTPCookie,
                                               availableVerification: Set<Verification>,
                                               onChange: @escaping (Result<Authentication.Response, Swift.Error>) -> Void) {
        self.storage = storage
        self.url = url
        self.crossSiteRequestForgery = crossSiteRequestForgery
        self.availableVerification = availableVerification
        self.onChange = onChange
    }
    
    // MARK: Checkpoint flow
    /// Request a code code through the selected `verification` method.
    /// - parameter verification: A `Verification` item to send the code to.
    public func requestCode(to verification: Verification) {
        Request(
            Endpoint(url: url)
                .body(key: "choice", value: verification.value)
                .headerFields(
                    ["Accept": "*/*",
                     "Accept-Language": "en-US",
                     "Accept-Encoding": "gzip, deflate",
                     "Connection": "close",
                     "x-csrftoken": crossSiteRequestForgery.value,
                     "x-requested-with": "XMLHttpRequest",
                     "Referer": "https://www.instagram.com",
                     "Authority": "www.instagram.com",
                     "Origin": url.absoluteString,
                     "Content-Type": "application/x-www-form-urlencoded"]
                )
        )
        .onComplete { [self] in
            switch $0 {
            case .failure(let error): self.onChange(.failure(error))
            default: break
            }
        }
        .resume()
    }
    
    /// Send the received code.
    /// - parameter code: A `String` containing the authentication code.
    public func send(code: String) {
        Request(
            Endpoint(url: url)
                .body(key: "security_code", value: code)
                .headerFields(
                    ["Accept": "*/*",
                     "Accept-Language": "en-US",
                     "Accept-Encoding": "gzip, deflate",
                     "Connection": "close",
                     "x-csrftoken": crossSiteRequestForgery.value,
                     "x-requested-with": "XMLHttpRequest",
                     "Referer": "https://www.instagram.com",
                     "Authority": "www.instagram.com",
                     "Origin": url.absoluteString,
                     "Content-Type": "application/x-www-form-urlencoded"]
                )
        )
        .onCompleteString { [self] in
            switch $0 {
            case .failure(let error): self.onChange(.failure(error))
            case .success(let value):
                // Try authenticating again.
                guard !value.data.contains("instagram://checkpoint/dismiss") else {
                    return self.onChange(.failure(AuthenticatorError.retry))
                }
                // Fetch `Authentication.Response`.
                let cookies = HTTPCookieStorage.shared.cookies?
                    .filter { ["sessionid", "ds_user_id"].contains($0.name) && $0.domain.contains(".instagram.com") }
                    .sorted { $0.name < $1.name } ?? []
                guard cookies.count == 2 else {
                    return self.onChange(.failure(AuthenticatorError.invalidCookies))
                }
                // Complete.
                self.onChange(.success(Authentication.Response(identifier: cookies[0],
                                                               crossSiteRequestForgery: self.crossSiteRequestForgery,
                                                               session: cookies[1])
                    .store(in: self.storage)))
            }
        }
        .resume()
    }
}
