import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    let always = [
        testCase(SwiftagramResponseTests.allTests),
        testCase(SwiftagramStorageTests.allTests),
        testCase(SwiftagramEndpointTests.allTests),
        testCase(SwiftagramAuthenticatorTests.allTests),
        testCase(SwiftagramExtensionsTests.allTests),
        testCase(SwiftagramCombineTests.allTests)
    ]
}
#endif
