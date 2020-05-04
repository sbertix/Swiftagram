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
@available(iOS 11, macOS 10.13, *)
internal final class WebView: WKWebView, WKNavigationDelegate {
    /// Any `Storage`.
    internal var storage: Storage!
    /// A block providing a `Secret`.
    internal var onChange: ((Result<Secret, Swift.Error>) -> Void)?

    /// A method called everytime a new page has finished loading.
    internal func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        switch webView.url?.absoluteString {
        case "https://www.instagram.com/"?:
            // Check the `WKWebView`.
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [self] in // keep alive.
                // Obtain cookies.
                let cookies = $0.filter { $0.domain.contains(".instagram.com") }
                // Prepare `Secret`.
                guard cookies.count >= 3 else {
                    self.onChange?(.failure(AuthenticatorError.invalidCookies))
                    return
                }
                self.onChange?(Secret(cookies: cookies).flatMap { .success($0.store(in: self.storage)) } ?? .failure(Secret.Error.invalidCookie))
            }
            // No need to check anymore.
            webView.navigationDelegate = nil
        default:
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [self] in // keep alive.
                // Obtain cookies.
                let cookies = $0.filter { $0.domain.contains(".instagram.com") }
                // Prepare `Secret` or do nothing.
                guard cookies.count >= 3 else { return }
                webView.navigationDelegate = nil
                self.onChange?(Secret(cookies: cookies).flatMap { .success($0.store(in: self.storage)) } ?? .failure(Secret.Error.invalidCookie))
                // Do not notify again.
                self.onChange = nil
            }
        }
    }
}
#endif
