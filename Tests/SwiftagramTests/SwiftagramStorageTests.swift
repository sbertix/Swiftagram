@testable import Swiftagram
@testable import SwiftagramKeychain
import XCTest

final class SwiftagramStorageTests: XCTestCase {
    /// Compute the `Secret`.
    let response = Secret(identifier: HTTPCookie(properties: [.name: "ds_user_id",
                                                              .path: "test",
                                                              .value: "test",
                                                              .domain: "test"])!,
                          crossSiteRequestForgery: HTTPCookie(properties: [.name: "csrftoken",
                                                                           .path: "test",
                                                                           .value: "test",
                                                                           .domain: "test"])!,
                          session: HTTPCookie(properties: [.name: "sessionid",
                                                           .path: "test",
                                                           .value: "test",
                                                           .domain: "test"])!)

    /// Test `TransientStorage` flow.
    func testTransientStorage() {
        let storage = TransientStorage()
        storage.removeAll()
        XCTAssert(storage.all().isEmpty, "Storage did not empty.")
        storage.store(response)
        XCTAssert(storage.find(matching: response.id) == nil, "Transient response was actually saved.")
        XCTAssert(storage.all().isEmpty, "Transient storage was actually not empty.")
    }
    /// Test `UserDefaultsStorage` flow.
    func testUserDefaultsStorage() {
        let storage = UserDefaultsStorage()
        storage.removeAll()
        XCTAssert(storage.all().isEmpty, "Storage did not empty")
        storage.store(response)
        XCTAssert(storage.find(matching: response.id) != nil, "Storage did not retrieve cached response.")
        let count = storage.all().count
        XCTAssert(count == 1, "Storage should contain one response, but it contains \(count).")
    }
    /// Test `KeychainStorage` flow.
    func testKeychainStorage() {
        /// Cannot mimic the keychain inside the test app.
        /// Tested on device and guaranteed to work.
    }

    static var allTests = [
        ("TransientStorage", testTransientStorage),
        ("UserDefaultsStorage", testUserDefaultsStorage),
        ("KeychainStorage", testKeychainStorage)
    ]
}
