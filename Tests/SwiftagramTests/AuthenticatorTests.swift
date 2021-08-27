//
//  AuthenticatorTests.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 17/08/2020.
//

#if !os(watchOS) && canImport(XCTest) && canImport(Combine)

import Combine
import Foundation
import XCTest

#if canImport(UIKit) && canImport(WebKit)
import UIKit
import WebKit
#endif

@testable import Swiftagram
@testable import SwiftagramCrypto

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
internal final class AuthenticatorTests: XCTestCase {
    /// The dispose bag.
    private var bin: Set<AnyCancellable> = []

    // MARK: Tests

    /// Test signing.
    func testSigning() {
        let request = Request("https://google.com")
        XCTAssert(
            request
                .signing(body: ["key": "value"])
                .body
                .flatMap { String(data: $0, encoding: .utf8) }?
                .removingPercentEncoding?
                .contains("{\"key\":\"value\"}") == true
        )
    }

    /// Test `BasicAuthenticator` login flow.
    func testBasicAuthenticator() {
        guard let password = ProcessInfo.processInfo.environment["PASSWORD"] else { return }
        let expectation = XCTestExpectation()
        Authenticator.userDefaults
            .basic(username: "swiftagram.tests",
                   password: password.trimmingCharacters(in: .whitespacesAndNewlines))
            .authenticate()
            .prepare(with: URLSessionCombineRequester(session: .ephemeral))
            .sink(
                receiveCompletion: {
                    switch $0 {
                    case .failure(let error):
                        switch error {
                        case Authenticator.Error.twoFactorChallenge(_):
                            break
                        default:
                            XCTFail(error.localizedDescription)
                        }
                    default:
                        XCTFail("This should never be called.")
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &bin)
        wait(for: [expectation], timeout: 60)
    }

    #if canImport(UIKit) && canImport(WebKit)

    /// Test `WebViewAuthenticator` login flow.
    ///
    /// This is not an actual test, as we can't test interface-based implementations with SPM.
    func testWebViewAuthenticator() {
        let expectation = XCTestExpectation()
        let view = UIView()
        Authenticator.userDefaults
            .visual(filling: view)
            .authenticate()
            .prepare(with: URLSessionCombineRequester(session: .ephemeral))
            .map { _ in () }
            .catch { _ in Just(()) }
            .sink { XCTFail("This should never be called.") }
            .store(in: &bin)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            self.bin.removeAll()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    #endif
}

#endif
