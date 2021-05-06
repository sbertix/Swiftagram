//
//  LoginView.swift
//  Authenticator
//
//  Created by Stefano Bertagno on 07/02/21.
//

import SwiftUI
import UIKit
import WebKit

import Swiftagram

/// A `class` defining a view controller capable of displaying the authentication web view.
class LoginViewController: UIViewController {
    /// The completion handler.
    var completion: ((Secret) -> Void)? {
        didSet {
            guard oldValue == nil, let completion = completion else { return }
            // Authenticate.
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                Authenticator.transient
                    .visual(filling: self.view)
                    .authenticate()
                    .sink(receiveCompletion: { _ in self.dismiss(animated: true, completion: nil) },
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
    /// A `Secret` binding.
    @Binding var secret: Secret?

    /// Compose the actual controller.
    ///
    /// - parameter context: A valid `Context`.
    /// - returns: A valid `LoginViewController`.
    func makeUIViewController(context: Context) -> LoginViewController {
        let controller = LoginViewController()
        controller.completion = { secret = $0 }
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
