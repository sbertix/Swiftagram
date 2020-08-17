import XCTest

import SwiftagramTests

var tests = [XCTestCaseEntry]()
tests += SwiftagramEndpointTests.allTests()
tests += SwiftagramAuthenticatorTests.allTests()
tests += SwiftagramModelsTests.allTests()
XCTMain(tests)
