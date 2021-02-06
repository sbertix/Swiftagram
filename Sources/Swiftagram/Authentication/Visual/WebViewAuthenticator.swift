//
//  WebViewAuthenticator.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 07/03/2020.
//

#if canImport(WebKit)
import Foundation
import WebKit

import ComposableRequest
import ComposableStorage

/// A `class` holding reference to a visual `Authenticator` relying on a custom web view to log in.
///
/// ## Usage
/// ```swift
/// class LoginViewController: UIViewController  {
///     /// The web view.
///     var webView: WKWebView? {
///         didSet {
///             oldValue?.removeFromSuperview() // Just in case.
///             guard let webView = webView else { return }
///             webView.frame = view.bounds     // Fill the parent view.
///             // You should also deal with layout constraints or similar here…
///             view.addSubview(webView)        // Add it to the parent view.
///         }
///     }
///
///     override func viewDidLoad() {
///         super.viewDidLoad()
///         // Authenticate using any `Storage` you want (`KeychainStorage` is used as an example).
///         WebViewAuthenticator(storage: KeychainStorage()) { self.webView = $0 }
///             .authenticate {
///                 switch $0 {
///                 case .failure(let error): print(error.localizedDescription)
///                 default: print("Logged in")
///                 }
///             }
///     }
/// ```
///
/// - warning: `Secret`s returned by `WebViewAuthenticator` are bound to the `Client` passed in the initialization process.
@available(iOS 11.0, macOS 10.13, macCatalyst 13.0, *)
public final class WebViewAuthenticator<Storage: ComposableStorage.Storage>: Authenticator where Storage.Item == Secret {
    /// A `Storage` instance used to store `Secret`s.
    public let storage: Storage

    /// A `Client` instance used to create the `Secret`s.
    public let client: Client

    /// A block outputing a configured `WKWebView`.
    /// A `String` holding a custom user agent to be passed to every request.
    var webView: (WKWebView) -> Void

    // MARK: Lifecycle

    /// Init.
    /// - parameters:
    ///     - storage: A concrete `Storage` value.
    ///     - client: A valid `Client`. Defaults to `.default`.
    ///     - webView: A block outputing a configured `WKWebView`.
    public init(storage: Storage,
                client: Client = .default,
                webView: @escaping (WKWebView) -> Void) {
        self.storage = storage
        self.client = client
        self.webView = webView
    }

    // MARK: Authenticator

    /// Return a `Secret` and store it in `storage`.
    ///
    /// - parameter onChange: A block providing a `Secret`.
    public func authenticate(_ onChange: @escaping (Result<Secret, Error>) -> Void) {
        // Delete all cookies.
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                                modifiedSince: .distantPast) { [self] in    // keep `self` alive.
                                                    // Update the process pool.
                                                    let configuration = WKWebViewConfiguration()
                                                    configuration.processPool = WKProcessPool()
                                                    let webView = WebView<Storage>(frame: .zero,
                                                                                   configuration: configuration,
                                                                                   storage: self.storage,
                                                                                   client: self.client,
                                                                                   onChange: onChange)
                                                    webView.navigationDelegate = webView
                                                    // Return the web view.
                                                    DispatchQueue.main.async {
                                                        self.webView(webView)
                                                        guard let url = URL(string: "https://www.instagram.com/accounts/login/") else {
                                                            return onChange(.failure(WebViewAuthenticatorError.invalidURL))
                                                        }
                                                        webView.load(URLRequest(url: url))
                                                    }
        }
    }
}

@available(iOS 11.0, macOS 10.13, macCatalyst 13.0, *)
public extension WebViewAuthenticator where Storage == ComposableStorage.TransientStorage<Secret> {
    /// Init.
    ///
    /// - parameters:
    ///     - client: A valid `Client`. Defaults to `.default`.
    ///     - webView: A block outputing a configured `WKWebView`.
    convenience init(client: Client = .default, webView: @escaping (WKWebView) -> Void) {
        self.init(storage: .init(), client: client, webView: webView)
    }
}
#endif
