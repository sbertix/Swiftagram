@testable import Swiftagram
import XCTest

final class SwiftagramExtensionsTests: XCTestCase {
    /// Test `String` extensions.
    func testString() {
        XCTAssert("camel_cased".camelCased == "camelCased")
        XCTAssert("snakeCased".snakeCased == "snake_cased")
        XCTAssert("begin".beginningWithUppercase == "Begin")
        XCTAssert("BEGIN".beginningWithLowercase == "bEGIN")
    }

    static var allTests = [
        ("String Extensions", testString)
    ]
}
