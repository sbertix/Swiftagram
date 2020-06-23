//
//  LoginView.swift
//  Followers
//
//  Created by Stefano Bertagno on 10/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//
import SwiftUI
import UIKit
import WebKit

import Swiftagram
import SwiftagramKeychain

class LoginViewController: UIViewController {
    /// The completion handler.
    var completion: ((Secret) -> Void)?
    /// The web view.
    var webView: WKWebView? {
        didSet {
            guard let webView = webView else { return }
            webView.frame = view.frame
            view.addSubview(webView)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Authenticate.
        WebViewAuthenticator(storage: KeychainStorage()) { self.webView = $0 }
            .authenticate { [weak self] in
                switch $0 {
                case .failure(let error): print(error.localizedDescription)
                case .success(let secret):
                    self?.completion?(secret)
                    self?.dismiss(animated: true, completion: nil)
                }
            }
    }
}

/// A `struct` defining a `View` used for logging in.
struct LoginView: UIViewControllerRepresentable {
    /// The current secret.
    @Binding var secret: Secret?

    func makeUIViewController(context: Context) -> LoginViewController {
        let controller = LoginViewController()
        controller.completion = { self.secret = $0 }
        return controller
    }
    func updateUIViewController(_ uiViewController: LoginViewController, context: Context) {
    }
}
