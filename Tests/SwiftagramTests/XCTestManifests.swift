import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwiftagramStorageTests.allTests),
        testCase(SwiftagramAuthenticatorTests.allTests)
    ]
}
#endif
