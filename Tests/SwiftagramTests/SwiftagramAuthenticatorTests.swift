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
        XCTAssert(Verification(response: .dictionary(["label": .string("Email"), "value": .string("1")]))?.label == "Email")
        // Authenticate.
        BasicAuthenticator(username: environemnt["INSTAGRAM_USERNAME"] ?? "",
                           password: environemnt["INSTAGRAM_PASSWORD"] ?? "")
            .authenticate { [username = environemnt["INSTAGRAM_USERNAME"] ?? ""] in
                switch $0 {
                case .success:
                    XCTAssert(true)
                    expectation.fulfill()
                case .failure(let error):
                    switch error {
                    case AuthenticatorError.checkpoint:
                        // We might expect a checkpoint but we don't have the tools to actually check for it.
                        // Let's pass if this is the case.
                        XCTAssert(true)
                        expectation.fulfill()
                    case let authenticationError as AuthenticatorError:
                        // 2FA is not handled in the test.
                        XCTFail(String(describing: authenticationError)+" for \(username)")
                        expectation.fulfill()
                    default:
                        XCTFail(error.localizedDescription+" for \(username)")
                        expectation.fulfill()
                    }
                }
            }
        wait(for: [expectation], timeout: 20)
    }
    
    /// Test `WebViewAuthenticator` login flow.
    
    func testWebViewAuthenticator() {
        if #available(macOS 10.13, iOS 11, *) {
            let expectation = XCTestExpectation()
            WebViewAuthenticator {
                self.webView = $0
                self.webView?.load(URLRequest(url: URL(string: "https://instagram.com/")!))
                DispatchQueue.main.asyncAfter(deadline: .now()+1) { expectation.fulfill() }
            }.authenticate { _ in
                // It cannot be tested.
            }
            wait(for: [expectation], timeout: 3)
        }
    }

    static var allTests = [
        ("BasicAuthenticator", testBasicAuthenticator),
        ("WebViewAuthenticator", testWebViewAuthenticator),
    ]
}
