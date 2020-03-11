import XCTest

import SwiftagramTests

var tests = [XCTestCaseEntry]()
tests += SwiftagramResponseTests.allTests()
tests += SwiftagramStorageTests.allTests()
tests += SwiftagramEndpointTests.allTests()
tests += SwiftagramAuthenticatorTests.allTests()
tests += SwiftagramExtensionsTests.allTests()
tests += SwiftagramCombineTests.allTests()
XCTMain(tests)
