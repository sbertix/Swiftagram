import ComposableRequest
@testable import Swiftagram
@testable import SwiftagramCrypto
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
        // removed implementation.
        let invalidUsername = XCTestExpectation()
        // Authenticate and checkpoint.
        let authenticator = BasicAuthenticator(username: "·····",
                                               password: "·····")
        authenticator.authenticate {
            switch $0 {
            case .failure(let error): print(error)
            case .success(let secret): print(secret); XCTFail("It should not succeed")
            }
            invalidUsername.fulfill()
        }
        wait(for: [invalidUsername], timeout: 60)
    }

    /// Test `TwoFactor`.
    func testTwoFactor() {
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        let expectation = XCTestExpectation()
        TwoFactor(username: "A",
                  identifier: "A",
                  crossSiteRequestForgery: .init(name: "_csrftoken", value: "A")) {
                    XCTAssert((try? $0.get()) == nil)
                    expectation.fulfill()
        }.send(code: "123456")
        wait(for: [expectation], timeout: 3)
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
            }
            .userAgent(UserAgent.default.string)
            .authenticate { _ in
                // It cannot be tested.
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    static var allTests = [
        ("Signing", testSigning),
        ("BasicAuthenticator", testBasicAuthenticator),
        ("TestTwoFactor", testTwoFactor),
        ("WebViewAuthenticator", testWebViewAuthenticator)
    ]
}
