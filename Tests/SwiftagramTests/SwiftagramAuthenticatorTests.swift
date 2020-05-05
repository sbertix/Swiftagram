import ComposableRequest
@testable import Swiftagram
import XCTest
#if canImport(WebKit)
import WebKit
#endif

final class SwiftagramAuthenticatorTests: XCTestCase {
    /// Environmental variables.
    var environemnt: [String: String] = [:]

    #if canImport(WebKit)
    /// The web view.
    var webView: WKWebView?
    #endif

    /// Set up.
    override func setUp() {
        environemnt = ProcessInfo.processInfo.environment
    }

    /// Test `BasicAuthenticator` login flow.
    func testBasicAuthenticator() {
        let expectation = XCTestExpectation(description: "BasicAuthenticator")
        let invalidUsername = XCTestExpectation()
        let checkpoint = XCTestExpectation()
        XCTAssert(Verification(response: ["label": "Email", "value": "1"])?.label == "Email")
        // Wrong username.
        BasicAuthenticator(username: "°°°°°°°°",
                           password: "°°°°°°°°")
            .authenticate {
                switch $0 {
                case .failure: break
                default: XCTFail("It should not succeed")
                }
                invalidUsername.fulfill()
        }
        // Authenticate and checkpoint.
        let authenticator = BasicAuthenticator(username: environemnt["INSTAGRAM_USERNAME"] ?? "",
                                               password: environemnt["INSTAGRAM_PASSWORD"] ?? "")
        authenticator.authenticate { [username = environemnt["INSTAGRAM_USERNAME"] ?? ""] in
                switch $0 {
                case .success:
                    XCTAssert(true)
                    expectation.fulfill()
                case .failure(let error):
                    switch error {
                    case AuthenticatorError.checkpoint:
                        // We might expect a checkpoint but we don't have the tools to actually check for it.
                        // Let's pass if this is the case.
                        break
                    case let authenticationError as AuthenticatorError:
                        // 2FA is not handled in the test.
                        XCTFail(String(describing: authenticationError)+" for \(username)")
                    default:
                        XCTFail(error.localizedDescription+" for \(username)")
                    }
                    expectation.fulfill()
                }
        }
        authenticator.handleCheckpoint(checkpoint: "",
                                       crossSiteRequestForgery: .init()) {
                                        switch $0 {
                                        case .failure: break
                                        case .success: XCTFail("It shouldn't succeed.")
                                        }
                                        checkpoint.fulfill()
        }
        wait(for: [expectation, invalidUsername, checkpoint], timeout: 60)
    }

    /// Test `TwoFactor`.
    func testTwoFactor() {
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        let expectation = XCTestExpectation()
        TwoFactor(storage: TransientStorage(),
                  username: "A",
                  identifier: "A",
                  userAgent: "A",
                  crossSiteRequestForgery: .init()) {
                    XCTAssert((try? $0.get()) == nil)
                    expectation.fulfill()
        }.send(code: "123456")
        wait(for: [expectation], timeout: 3)
    }

    /// Test `TwoFactor`.
    func testCheckpoint() {
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        let expectation = XCTestExpectation()
        let verification = Verification(response: ["label": "email", "value": "1"])!
        let checkpoint = Checkpoint(storage: TransientStorage(),
                                    url: URL(string: "/")!,
                                    userAgent: "A",
                                    crossSiteRequestForgery: .init(),
                                    availableVerification: [verification]) {
                                        switch $0 {
                                        case .success: XCTFail("It should not work.")
                                        default: break
                                        }
                                        expectation.fulfill()
        }
        checkpoint.requestCode(to: verification)
        checkpoint.send(code: "123456")
        wait(for: [expectation], timeout: 10)
    }

    /// Test `WebViewAuthenticator` login flow.
    func testWebViewAuthenticator() {
        if #available(macOS 10.13, iOS 11, *) {
            let expectation = XCTestExpectation()
            WebViewAuthenticator {
                self.webView = $0
                self.webView?.load(URLRequest(url: URL(string: "https://google.com/")!))
                DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                    self.webView?.load(URLRequest(url: URL(string: "https://instagram.com/")!))
                    DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                        expectation.fulfill()
                    }
                }
            }.authenticate { _ in
                // It cannot be tested.
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    static var allTests = [
        ("BasicAuthenticator", testBasicAuthenticator),
        ("WebViewAuthenticator", testWebViewAuthenticator)
    ]
}
