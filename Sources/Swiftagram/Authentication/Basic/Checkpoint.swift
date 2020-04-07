//
//  Checkpoint.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

import ComposableRequest
import Foundation

/// A `class` holding reference to a `Checkpoint`.
public final class Checkpoint {
    /// Any `Storage`.
    internal let storage: Storage
    /// A `URL` originating the `Checkpoint`.
    internal let url: URL
    /// A `String` representing the user agent to be used for every request.
    internal let userAgent: String
    /// A `HTTPCookie` for `csrftoken`.
    internal let crossSiteRequestForgery: HTTPCookie
    /// A `Set` of `Verification` representing available methods.
    public let availableVerification: Set<Verification>
    /// A block providing a `Secret`.
    internal let onChange: (Result<Secret, Swift.Error>) -> Void

    // MARK: Lifecycle
    /// Init.
    internal init<Storage: Swiftagram.Storage>(storage: Storage,
                                               url: URL,
                                               userAgent: String,
                                               crossSiteRequestForgery: HTTPCookie,
                                               availableVerification: Set<Verification>,
                                               onChange: @escaping (Result<Secret, Swift.Error>) -> Void) {
        self.storage = storage
        self.url = url
        self.userAgent = userAgent
        self.crossSiteRequestForgery = crossSiteRequestForgery
        self.availableVerification = availableVerification
        self.onChange = onChange
    }

    // MARK: Checkpoint flow
    /// Request a code code through the selected `verification` method.
    /// - parameter verification: A `Verification` item to send the code to.
    public func requestCode(to verification: Verification) {
        Request(url)
            .body("choice", value: verification.value)
            .header(
                ["Accept": "*/*",
                 "Accept-Language": "en-US",
                 "Accept-Encoding": "gzip, deflate",
                 "Connection": "close",
                 "x-csrftoken": crossSiteRequestForgery.value,
                 "x-requested-with": "XMLHttpRequest",
                 "Referer": "https://www.instagram.com",
                 "Authority": "www.instagram.com",
                 "Origin": url.absoluteString,
                 "Content-Type": "application/x-www-form-urlencoded",
                 "User-Agent": userAgent]
            )
            .task(by: .authentication) { [self] in
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
        Request(url)
            .body("security_code", value: code)
            .header(
                ["Accept": "*/*",
                 "Accept-Language": "en-US",
                 "Accept-Encoding": "gzip, deflate",
                 "Connection": "close",
                 "x-csrftoken": crossSiteRequestForgery.value,
                 "x-requested-with": "XMLHttpRequest",
                 "Referer": "https://www.instagram.com",
                 "Authority": "www.instagram.com",
                 "Origin": url.absoluteString,
                 "Content-Type": "application/x-www-form-urlencoded",
                 "User-Agent": userAgent]
            )
            .expecting(String.self)
            .task(by: .authentication) { [self] in
                switch $0 {
                case .failure(let error): self.onChange(.failure(error))
                case .success(let value):
                    // Try authenticating again.
                    guard !value.contains("instagram://checkpoint/dismiss") else {
                        return self.onChange(.failure(AuthenticatorError.retry))
                    }
                    // Fetch `Secret`.
                    let cookies = HTTPCookieStorage.shared.cookies?
                        .filter { ["sessionid", "ds_user_id"].contains($0.name) && $0.domain.contains(".instagram.com") }
                        .sorted { $0.name < $1.name } ?? []
                    guard cookies.count == 2 else {
                        return self.onChange(.failure(AuthenticatorError.invalidCookies))
                    }
                    // Complete.
                    self.onChange(.success(Secret(identifier: cookies[0],
                                                  crossSiteRequestForgery: self.crossSiteRequestForgery,
                                                  session: cookies[1])
                        .store(in: self.storage)))
                }
            }
            .resume()
    }
}
