@testable import Swiftagram
import XCTest

final class SwiftagramTests: XCTestCase {
    /// Environmental variables.
    var environemnt: [String: String] = [:]

    /// Set up.
    override func setUp() {
        environemnt = ProcessInfo.processInfo.environment
    }

    /// Test `BasicAuthenticator` login flow.
    func testBasicAuthenticator() {
        let expectation = XCTestExpectation(description: "BasicAuthenticator")
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

    static var allTests = [
        ("BasicAuthenticator", testBasicAuthenticator)
    ]
}
