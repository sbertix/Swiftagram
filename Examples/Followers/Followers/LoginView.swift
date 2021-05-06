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
import SwiftagramCrypto

/// A `class` defining a view controller capable of displaying the authentication web view.
class LoginViewController: UIViewController {
    /// The completion handler.
    var completion: ((Secret) -> Void)? {
        didSet {
            guard oldValue == nil, let completion = completion else { return }
            // Authenticate.
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                Authenticator.keychain
                    .visual(filling: self.view)
                    .authenticate()
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { print($0); self.dismiss(animated: true, completion: nil) },
                          receiveValue: completion)
                    .store(in: &self.bin)
            }
        }
    }

    /// The dispose bag.
    private var bin: Set<AnyCancellable> = []
}

/// A `struct` defining a `View` used for logging in.
struct LoginView: UIViewControllerRepresentable {
    /// A completion handler.
    let didAuthenticate: (Secret) -> Void

    /// Compose the actual controller.
    ///
    /// - parameter context: A valid `Context`.
    /// - returns: A valid `LoginViewController`.
    func makeUIViewController(context: Context) -> LoginViewController {
        let controller = LoginViewController()
        controller.completion = didAuthenticate
        return controller
    }

    /// Update the controller.
    ///
    /// - parameters:
    ///     - uiViewController: A valid `LoginViewController`.
    ///     - context: A valid `Context`.
    func updateUIViewController(_ uiViewController: LoginViewController, context: Context) {
    }
}
