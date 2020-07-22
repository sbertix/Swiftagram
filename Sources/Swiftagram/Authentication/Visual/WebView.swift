//
//  WebView.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 09/03/2020.
//

#if canImport(WebKit)
import Foundation
import WebKit

/// A `class` describing a self-navigating `WKWebView`.
@available(iOS 11, macOS 10.13, macCatalyst 13, *)
internal final class WebView: WKWebView, WKNavigationDelegate {
    /// Any `Storage`.
    internal var storage: Storage!
    /// A block providing a `Secret`.
    internal var onChange: ((Result<Secret, WebViewAuthenticatorError>) -> Void)?

    /// A method called everytime a new page has finished loading.
    internal func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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
                guard cookies.count >= 3 else {
                    self.onChange?(.failure(.invalidCookies))
                    return
                }
                self.onChange?(Secret(cookies: cookies).flatMap { .success($0.store(in: self.storage)) } ?? .failure(.invalidCookies))
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
                self.onChange?(Secret(cookies: cookies).flatMap { .success($0.store(in: self.storage)) } ?? .failure(.invalidCookies))
                // Do not notify again.
                self.onChange = nil
            }
        }
    }
}
#endif
