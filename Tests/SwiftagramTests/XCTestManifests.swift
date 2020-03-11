import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwiftagramResponseTests.allTests),
        testCase(SwiftagramStorageTests.allTests),
        testCase(SwiftagramEndpointTests.allTests),
        testCase(SwiftagramAuthenticatorTests.allTests),
        testCase(SwiftagramExtensionsTests.allTests)
    ]
}
#endif
