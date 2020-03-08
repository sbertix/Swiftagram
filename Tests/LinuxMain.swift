import XCTest

import SwiftagramTests

var tests = [XCTestCaseEntry]()
tests += SwiftagramStorageTests.allTests()
tests += SwiftagramAuthenticatorTests.allTests()
XCTMain(tests)
