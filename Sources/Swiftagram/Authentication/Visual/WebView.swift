//
//  WebView.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 09/03/2020.
//

#if canImport(WebKit)
import Foundation
import WebKit

/// A `class` holding reference to a specialized `WKWebView`.
///
/// - note: This should **only** be used for Instagram authentication.
@available(iOS 11, macOS 10.13, macCatalyst 13, *)
final class WebView<Storage: ComposableStorage.Storage>: WKWebView, WKNavigationDelegate where Storage.Item == Secret {
    /// Any `Storage`.
    let storage: Storage
    /// A `Client` instance used to create the `Secret`s.
    let client: Client
    /// A block providing a `Secret`.
    private(set) var onChange: ((Result<Secret, Error>) -> Void)?

    // MARK: Lifecycle

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
                  onChange: @escaping (Result<Secret, Error>) -> Void) {
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

    // MARK: Web View

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
                guard cookies.containsAuthenticationCookies else {
                    self.onChange?(.failure(WebViewAuthenticatorError.invalidCookies))
                    return
                }
                self.onChange?(
                    Secret(cookies: cookies, client: self.client)
                        .flatMap { secret in Result { try Storage.store(secret, in: self.storage) }}
                        ?? .failure(WebViewAuthenticatorError.invalidCookies)
                )
            }
            // No need to check anymore.
            webView.navigationDelegate = nil
        default:
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [self] in // keep alive.
                // Obtain cookies.
                let cookies = $0.filter { $0.domain.contains(".instagram.com") }
                // Prepare `Secret` or do nothing.
                guard cookies.containsAuthenticationCookies else { return }
                webView.navigationDelegate = nil
                self.onChange?(
                    Secret(cookies: cookies, client: self.client)
                        .flatMap { secret in Result { try Storage.store(secret, in: self.storage) }}
                        ?? .failure(WebViewAuthenticatorError.invalidCookies)
                )
                // Do not notify again.
                self.onChange = nil
            }
        }
    }
}
#endif
