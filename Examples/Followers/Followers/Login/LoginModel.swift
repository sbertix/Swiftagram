//
//  LoginModel.swift
//  Ghoster
//
//  Created by Stefano Bertagno on 23/03/2020.
//  Copyright © 2020 Stefano Bertagno. All rights reserved.
//

import Combine
import Foundation

import ComposableRequest
import Swiftagram
import SwiftagramKeychain

final class LoginModel: ObservableObject {
    /// The different stages.
    enum Stage: Equatable {
        case authentication
        case authenticating
        case challenge(String)
        case failed(String)
        case done
        indirect case invalid(Stage)

        /// The button title.
        var button: String {
            switch self {
            case .invalid(let stage):
                switch stage {
                case .challenge(let label): return "A code was sent to your "+label+"."
                default: return stage.button
                }
            case .authentication: return "Sign in"
            case .authenticating: return "Signing in…"
            case .challenge: return "Sign in"
            case .failed(let error): return error+"\nTap to retry."
            case .done: return "Done!"
            }
        }

        /// Should show username and password.
        var shouldDisplayBasicAuth: Bool { self.valid == .authentication }

        /// Should show code.
        var shouldDisplayCode: Bool { if case .challenge = valid { return true }; return false }

        /// Whether it's locked or not.
        var isLocked: Bool {
            switch self {
            case .authentication, .challenge, .failed: return false
            default: return true
            }
        }

        /// The valid underlying stage.
        var valid: Stage {
            switch self {
            case .invalid(let stage): return stage.valid
            default: return self
            }
        }
    }

    /// The user's profile username.
    @Published var username: String = ""
    /// The user's profile password.
    @Published var password: String = ""
    /// The one time code.
    @Published var code: String = ""
    /// The current stage.
    @Published var stage: Stage = .invalid(.authentication)
    /// The authenticated secret.
    @Published var secret: Secret?

    /// The current checkpoint.
    private var checkpoint: Checkpoint?
    /// The current two factor authenticator.
    private var twoFactor: TwoFactor?

    /// The stage cancellable.
    var invalidCancellable: AnyCancellable?

    // MARK: Lifecycle
    init() {
        invalidCancellable = $username.combineLatest($password)
            .map { $0.isEmpty || $1.isEmpty }
            .merge(with: $code.map { $0.isEmpty })
            .removeDuplicates()
            .compactMap { [unowned self] in
                !$0 ? self.stage.valid : .invalid(self.stage.valid)
            }
            .removeDuplicates()
            .assign(to: \.stage, on: self)
    }

    // MARK: Advance
    /// Advance to the next `stage` if `stage` is not `.invalid`.
    func advance() {
        switch stage {
        case .authentication:
            self.stage = .authenticating
            // authenticate.
            BasicAuthenticator(storage: KeychainStorage(),
                               username: username,
                               password: password)
                .authenticate { [weak self] in
                    switch $0 {
                    case .success(let secret):
                        self?.secret = secret
                    case .failure(let error):
                        switch error {
                        case AuthenticatorError.checkpoint(let checkpoint):
                            // ask code for verification.
                            guard let verification = checkpoint?.availableVerification.first else {
                                self?.stage = .failed(error.localizedDescription)
                                break
                            }
                            checkpoint?.requestCode(to: verification)
                            self?.checkpoint = checkpoint
                            self?.stage = .invalid(.challenge(verification.label))
                        case AuthenticatorError.twoFactor(let twoFactor):
                            self?.twoFactor = twoFactor
                            self?.stage = .invalid(.challenge("2FA app or mobile phone"))
                        default:
                            self?.stage = .failed(error.localizedDescription)
                        }
                    }
                }
        case .challenge:
            // solve challenge.
            self.checkpoint?.send(code: code)
            self.twoFactor?.send(code: code)
            self.stage = .authenticating
        case .failed:
            // retry.
            self.username = ""
            self.password = ""
            self.code = ""
            self.checkpoint = nil
            self.twoFactor = nil
            self.stage = .invalid(.authentication)
        default:
            break
        }
    }
}
