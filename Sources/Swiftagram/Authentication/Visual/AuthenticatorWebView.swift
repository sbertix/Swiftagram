//
//  AuthenticatorWebView.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 09/04/21.
//

#if canImport(UIKit) && canImport(WebKit)

import Foundation
import WebKit

/// A `class` holding reference to a specialized `WKWebView`.
///
/// - note: This should **only** be used for Instagram authentication.
@available(iOS 11, macOS 10.13, macCatalyst 13, *)
internal final class AuthenticatorWebView: WKWebView, WKNavigationDelegate {
    /// The underlying client.
    private let client: Client
    /// Whether it's still authenticating or not.
    private var isAuthenticating: Bool = true {
        didSet {
            switch isAuthenticating {
            case true:
                navigationDelegate = self
                isUserInteractionEnabled = true
                isHidden = false
            case false:
                navigationDelegate = nil
                isUserInteractionEnabled = false
                isHidden = true
            }
        }
    }
    /// A semaphore used for processing data safely.
    private let semaphore: DispatchSemaphore = .init(value: 1)
    /// The actual authenticator subject.
    private let subject: CurrentValueSubject<Secret?, Swift.Error> = .init(nil)

    /// The authenticator publisher.
    lazy var secret: AnyPublisher<Secret, Swift.Error> = { subject.compactMap { $0 }.eraseToAnyPublisher() }()

    /// Init.
    ///
    /// - parameter client: A valid `Client`.
    required init(client: Client) {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = WKProcessPool()
        configuration.userContentController
            .addUserScript(
                .init(
                    source: """
                    // Remove "download from Google Play" header.
                    const googlePlay = document.getElementsByClassName('MFkQJ ABLKx VhasA _1-msldsad')?.[0]
                        || document.getElementsByClassName('MFkQJ ABLKx VhasA _1-msl')?.[0];
                    if (googlePlay) googlePlay.remove()
                    // Remove cookie bar.
                    const cookieBar = document.getElementsByClassName('lOPC8 DPEif')?.[0];
                    if (cookieBar) cookieBar.remove();
                    // Remove FB unsupported browser.
                    const headerNotice = document.getElementById('header-notices');
                    if (headerNotice) headerNotice.remove();
                    """,
                    injectionTime: .atDocumentEnd,
                    forMainFrameOnly: true)
            )
        // Init.
        self.client = client
        super.init(frame: .zero, configuration: configuration)
        self.customUserAgent = client.browserDescription
        self.navigationDelegate = self
    }

    /// Init.
    ///
    /// - parameter coder: A valid `NSCoder`.
    /// - warning: This has not been implemeneted and will not be.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented: do not use `WebView` in your Storyboards")
    }

    // MARK: Web View

    /// A method called everytime a new page has finished loading.
    ///
    /// - parameters:
    ///     - webView: A valid `WKWebView`.
    ///     - navigation: An optional `WKNavigation`.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard isAuthenticating else { return }
        // Auto-accept cookies.
        if webView.url?.absoluteString.contains("https://www.instagram.com/accounts/login") ?? false {
            webView.evaluateJavaScript("""
                // Allow all cookies.
                const cookieAlert = document.getElementsByClassName("aOOlW  bIiDR  ")?.[0];
                if (cookieAlert) cookieAlert.click();
            """) { _, _ in }
        }
        // Deal with authentication-related logic.
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            self.semaphore.wait() // Wait for a signal.
            guard self.isAuthenticating else { self.semaphore.signal(); return }
            // Fetch the cookies.
            DispatchQueue.main.async { [self] in
                webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [self] in
                    let cookies = $0.filter { $0.domain.contains(".instagram.com") }
                    switch Secret(cookies: cookies, client: self.client) {
                    case let secret?:
                        self.subject.send(secret)
                        self.subject.send(completion: .finished)
                        self.isAuthenticating = false
                    default:
                        // Only notify an error if we're on the home page.
                        guard webView.url?.absoluteString == "https://www.instagram.com/" else { break }
                        self.subject.send(completion: .failure(Authenticator.Error.invalidCookies(cookies)))
                        self.isAuthenticating = false
                    }
                    self.semaphore.signal()
                }
            }
        }
    }
}

#endif
