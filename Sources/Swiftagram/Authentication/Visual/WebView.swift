//
//  WebView.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 09/03/2020.
//

#if canImport(WebKit)
import Foundation
import WebKit

import ComposableRequest

/// A `class` describing a self-navigating `WKWebView`.
@available(iOS 11, macOS 10.13, macCatalyst 13, *)
internal final class WebView<Storage: ComposableRequest.Storage>: WKWebView, WKNavigationDelegate where Storage.Key == Secret {
    /// Any `Storage`.
    let storage: Storage
    /// A `Client` instance used to create the `Secret`s.
    let client: Client
    /// A block providing a `Secret`.
    private(set) var onChange: ((Result<Secret, WebViewAuthenticatorError>) -> Void)?

    /// Init.
    ///
    /// - parameters:
    ///     - frame: A valid `CGRect`.
    ///     - configuration: A valid `WKWebViewConfiguration`.
    ///     - storage: A valid `Storage`.
    ///     - client: A valid `Client`.
    ///     - onChange: A valid completion block.
    required init(frame: CGRect,
                  configuration: WKWebViewConfiguration,
                  storage: Storage,
                  client: Client,
                  onChange: @escaping (Result<Secret, WebViewAuthenticatorError>) -> Void) {
        self.storage = storage
        self.client = client
        self.onChange = onChange
        super.init(frame: frame, configuration: configuration)
        self.customUserAgent = client.browserDescription
    }

    /// Init.
    ///
    /// - parameter coder: A valid `NSCoder`.
    /// - warning: This has not been implemeneted and will not be.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented: do not use `WebView` in your Storyboards")
    }

    /// A method called everytime a new page has finished loading.
    ///
    /// - parameters:
    ///     - webView: A valid `WKWebView`.
    ///     - navigation: An optional `WKNavigation`.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        switch webView.url?.absoluteString {
        case "https://www.instagram.com/accounts/login/"?:
            webView.evaluateJavaScript("""
            const googlePlay = document.getElementsByClassName('MFkQJ ABLKx VhasA _1-msldsad')[0]
                || document.getElementsByClassName('MFkQJ ABLKx VhasA _1-msl')[0];
            if (googlePlay) googlePlay.remove();
            const cookies = document.getElementsByClassName('lOPC8 DPEif')[0];
            if (cookies) cookies.remove();
            """, completionHandler: { _, _ in })
        case "https://www.instagram.com/"?:
            // Check the `WKWebView`.
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [self] in // keep alive.
                // Obtain cookies.
                let cookies = $0.filter { $0.domain.contains(".instagram.com") }
                // Prepare `Secret`.
                guard Secret.hasValidCookies(cookies) else {
                    self.onChange?(.failure(.invalidCookies))
                    return
                }
                self.onChange?(
                    Secret(cookies: cookies, client: self.client).flatMap { .success($0.store(in: self.storage)) } ?? .failure(.invalidCookies)
                )
            }
            // No need to check anymore.
            webView.navigationDelegate = nil
        default:
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [self] in // keep alive.
                // Obtain cookies.
                let cookies = $0.filter { $0.domain.contains(".instagram.com") }
                // Prepare `Secret` or do nothing.
                guard Secret.hasValidCookies(cookies) else { return }
                webView.navigationDelegate = nil
                self.onChange?(
                    Secret(cookies: cookies, client: self.client).flatMap { .success($0.store(in: self.storage)) } ?? .failure(.invalidCookies)
                )
                // Do not notify again.
                self.onChange = nil
            }
        }
    }
}
#endif
