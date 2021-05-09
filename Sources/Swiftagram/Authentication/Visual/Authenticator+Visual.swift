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

import ComposableStorage

public extension Authenticator.Group {
    /// A `struct` defining an authenticator relying on `WKWebView`s to log in.
    @available(iOS 11.0, macOS 10.13, macCatalyst 13.0, *)
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
        /// - returns: A valid `Publisher`.
        public func authenticate(in client: Client) -> AnyPublisher<Secret, Swift.Error> {
            Deferred {
                Future<Void, Never> { resolve in
                    // Delete all instagram records.
                    let store = WKWebsiteDataStore.default()
                    store.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) {
                        let instagramRecords = $0.filter { $0.displayName.contains("instagram") }
                        store.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: instagramRecords) {
                            resolve(.success(()))
                        }
                    }
                }
                .setFailureType(to: Swift.Error.self)
                .flatMap {
                    Future<AuthenticatorWebView, Swift.Error> { resolve in
                        // Prepare the actual `WebView`.
                        let webView = AuthenticatorWebView(client: client)
                        self.transformer(webView) {
                            guard let url = URL(string: "https://www.instagram.com/accounts/login/") else {
                                return resolve(.failure(Authenticator.Error.invalidURL))
                            }
                            webView.load(.init(url: url))
                            resolve(.success(webView))
                        }
                    }
                }
                .flatMap(\.secret)
                .tryMap { try AnyStorage<Secret>.store($0, in: self.authenticator.storage) }
            }
            .subscribe(on: RunLoop.main)
            .receive(on: RunLoop.main)
            .prefix(1)
            .eraseToAnyPublisher()
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
