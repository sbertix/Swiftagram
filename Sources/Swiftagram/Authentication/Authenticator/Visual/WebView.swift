//
//  WebView.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 09/03/2020.
//

#if canImport(WebKit)
import Foundation
import WebKit

@available(iOS 11, macOS 10.13, *)
/// A `class` describing a self-navigating `WKWebView`.
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
                let cookies = $0.filter {
                    $0.domain.contains(".instagram.com") && ["ds_user_id", "sessionid", "csrftoken"].contains($0.name)
                }.sorted { $0.name < $1.name }
                // Prepare `Secret`.
                guard cookies.count == 3 else {
                    self.onChange?(.failure(AuthenticatorError.invalidCookies))
                    return
                }
                self.onChange?(.success(Secret(identifier: cookies[1],
                                               crossSiteRequestForgery: cookies[0],
                                               session: cookies[2]).store(in: self.storage)))
            }
            // No need to check anymore.
            webView.navigationDelegate = nil
        default:
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [self] in // keep alive.
                // Obtain cookies.
                let cookies = $0.filter {
                    $0.domain.contains(".instagram.com") && ["ds_user_id", "sessionid", "csrftoken"].contains($0.name)
                }.sorted { $0.name < $1.name }
                // Prepare `Secret` or do nothing.
                guard cookies.count == 3 else { return }
                webView.navigationDelegate = nil
                self.onChange?(.success(Secret(identifier: cookies[1],
                                               crossSiteRequestForgery: cookies[0],
                                               session: cookies[2]).store(in: self.storage)))
                // Do not notify again.
                self.onChange = nil
            }
        }
    }
}
#endif
