import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    let always = [
        testCase(SwiftagramStorageTests.allTests),
        testCase(SwiftagramEndpointTests.allTests),
        testCase(SwiftagramAuthenticatorTests.allTests)
    ]
}
#endif
