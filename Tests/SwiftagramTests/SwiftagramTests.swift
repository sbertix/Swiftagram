import XCTest
@testable import Swiftagram

final class SwiftagramTests: XCTestCase {
    /// Environmental variables.
    var environemnt: [String: String] = [:]
    
    /// Set up.
    override func setUp(){
        environemnt = ProcessInfo.processInfo.environment
    }

    /// Test `BasicAuthenticator` login flow.
    func testBasicAuthenticator() {
        let expectation = XCTestExpectation(description: "BasicAuthenticator")
        // Authenticate.
        BasicAuthenticator(username: environemnt["INSTAGRAM_USERNAME"] ?? "",
                           password: environemnt["INSTAGRAM_PASSWORD"] ?? "")
            .authenticate {
                switch $0 {
                case .success:
                    XCTAssert(true)
                    expectation.fulfill()
                case .failure(let error):
                    switch error {
                    case let authenticationError as AuthenticatorError:
                        // Checkpoints and 2FA are not handled in the test.
                        XCTFail(String(describing: authenticationError))
                        expectation.fulfill()
                    default:
                        XCTFail(error.localizedDescription)
                        expectation.fulfill()
                    }
                }
            }
        wait(for: [expectation], timeout: 20)
    }

    static var allTests = [
        ("BasicAuthenticator", testBasicAuthenticator),
    ]
}
