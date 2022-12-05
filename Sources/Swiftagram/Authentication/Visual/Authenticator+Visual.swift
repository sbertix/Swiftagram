//
//  Authenticator+Visual.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 09/04/21.
//

#if canImport(UIKit) && canImport(WebKit)

import Foundation
import UIKit
import WebKit

import Requests
import Storages

public extension Authenticator.Group {
    /// A `struct` defining an authenticator relying on `WKWebView`s to log in.
    struct Visual: CustomClientAuthentication {
        /// The underlying authenticator.
        public let authenticator: Authenticator
        /// The web view transformer.
        private let transformer: (_ webView: WKWebView, _ completion: @escaping () -> Void) -> Void

        /// Init.
        ///
        /// - parameters:
        ///     - authenticator: A valid `Authenticator`.
        ///     - transformer: A valid web view transformer.
        /// - note: Use `authenticator.visual(_:)` and related, instead.
        fileprivate init(authenticator: Authenticator,
                         transformer: @escaping (_ webView: WKWebView, _ completion: @escaping () -> Void) -> Void) {
            self.authenticator = authenticator
            self.transformer = transformer
        }

        /// Authenticate the given user.
        ///
        /// - parameter client: A valid `Client`.
        /// - returns: Some `SingleEndpoint`.
        public func authenticate(in client: Client) -> AnySingleEndpoint<Secret> {
            Static {
                // Delete all instagram records.
                let store = WKWebsiteDataStore.default()
                await withUnsafeContinuation { continuation in
                    store.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) {
                        let records = $0.filter { $0.displayName.contains("instagram") }
                        store.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records) {
                            continuation.resume()
                        }
                    }
                }
            }.switch {
                // Prepare the actual web view.
                let webView: AuthenticatorWebView = .init(client: client)
                try await withCheckedThrowingContinuation { continuation in
                    transformer(webView) {
                        guard let url = URL(string: "https://www.instagram.com/accounts/login/") else {
                            return continuation.resume(with: .failure(Authentication.Error.invalidURL))
                        }
                        webView.load(.init(url: url))
                        continuation.resume(with: .success(webView))
                    }
                }
            }.switch { webView in
                // Add the actual completion handler.
                try await withCheckedThrowingContinuation { continuation in
                    webView.completion = {
                        // Store inside the selected storage.
                        AnyStorage<Secret>.store($0, in: authenticator.storage)
                        // Return.
                        continuation.resume(with: $0)
                    }
                }
            }.eraseToAnySingleEndpoint()
        }
    }
}

public extension Authenticator {
    /// Authenticate using a `WKWebView`.
    /// You're responsibile for adding the web view to your view hierarchy and
    /// calling the completion handler.
    ///
    /// - parameter transformer: A valid web view transformer.
    /// - returns: A valid `Group.Visual`.
    func visual(_ transformer: @escaping (_ webView: WKWebView, _ completion: @escaping () -> Void) -> Void) -> Group.Visual {
        .init(authenticator: self, transformer: transformer)
    }

    /// Authenticate using a `WKWebView`.
    /// You're responsible for adding the web view to your view hierarchy.
    ///
    /// - parameter transformer: A valid web view transformer.
    /// - returns: A valid `Group.Visual`.
    func visual(_ transformer: @escaping (_ webView: WKWebView) -> Void) -> Group.Visual {
        visual { transformer($0); $1() }
    }

    /// Authenticate using a `WKWebView`.
    /// The web view will be added as a child of `superview`.
    ///
    /// - parameter superview: A valid `UIView`.
    /// - returns: A valid `Group.Visual`.
    func visual(filling superview: UIView) -> Group.Visual {
        visual {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.frame = superview.bounds
            superview.addSubview($0)
            // Add constraints.
            NSLayoutConstraint.activate(
                [$0.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                 $0.topAnchor.constraint(equalTo: superview.topAnchor),
                 $0.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                 $0.bottomAnchor.constraint(equalTo: superview.bottomAnchor)]
            )
        }
    }
}

#endif
