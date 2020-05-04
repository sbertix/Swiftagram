@testable import Swiftagram
@testable import SwiftagramKeychain
import XCTest

final class SwiftagramStorageTests: XCTestCase {
    /// Compute the `Secret`.
    let response = Secret(cookies: [HTTPCookie(properties: [.name: "ds_user_id",
                                                            .path: "test",
                                                            .value: "test",
                                                            .domain: "test"])!,
                                    HTTPCookie(properties: [.name: "csrftoken",
                                                            .path: "test",
                                                            .value: "test",
                                                            .domain: "test"])!,
                                    HTTPCookie(properties: [.name: "sessionid",
                                                            .path: "test",
                                                            .value: "test",
                                                            .domain: "test"])!])

    /// Test `TransientStorage` flow.
    func testTransientStorage() {
        let storage = TransientStorage()
        storage.removeAll()
        XCTAssert(storage.all().isEmpty, "Storage did not empty.")
        storage.store(response)
        XCTAssert(storage.find(matching: response.identifier) == nil, "Transient response was actually saved.")
        XCTAssert(storage.all().isEmpty, "Transient storage was actually not empty.")
        XCTAssert(storage.remove(matching: response.identifier) == nil, "Transient storage was actually not empty.")
    }
    /// Test `UserDefaultsStorage` flow.
    func testUserDefaultsStorage() {
        let storage = UserDefaultsStorage()
        storage.removeAll()
        XCTAssert(storage.all().isEmpty, "Storage did not empty")
        storage.store(response)
        XCTAssert(storage.find(matching: response.identifier) != nil, "Storage did not retrieve cached response.")
        let count = storage.all().count
        XCTAssert(count == 1, "Storage should contain one response, but it contains \(count).")
        storage.removeAll()
        XCTAssert(storage.all().isEmpty, "Transient storage was actually not empty.")
    }
    /// Test `UserDefaultsStorage` flow as `[Storage]`.
    func testStorage() {
        let storage = [UserDefaultsStorage()]
        storage.removeAll()
        XCTAssert(storage.all().isEmpty, "Storage did not empty")
        storage.store(response)
        XCTAssert(storage.find(matching: response.identifier) != nil, "Storage did not retrieve cached response.")
        let count = storage.all().count
        XCTAssert(count == 1, "Storage should contain one response, but it contains \(count).")
        storage.removeAll()
        XCTAssert(storage.all().isEmpty, "Transient storage was actually not empty.")
    }
    /// Test `KeychainStorage` flow.
    func testKeychainStorage() {
        // Keychain is not available during test.
        // So this should all return empty.
        let storage = KeychainStorage()
        storage.removeAll()
        XCTAssert(storage.all().isEmpty, "Storage did not empty.")
        storage.store(response)
        #if canImport(UIKit)
            XCTAssert(storage.find(matching: response.identifier) == nil, "Storage did not retrieve cached response.")
            XCTAssert(storage.remove(matching: response.identifier) == nil, "Transient storage was actually not empty.")
        #else
            XCTAssert(storage.find(matching: response.identifier) != nil, "Storage did not retrieve cached response.")
            XCTAssert(storage.remove(matching: response.identifier) != nil, "Transient storage was actually not empty.")
        #endif
        XCTAssert(storage.all().isEmpty, "Transient storage was actually not empty.")   // Always `nil` during test.
        storage.removeAll()
        XCTAssert(storage.all().isEmpty, "Transient storage was actually not empty.")
    }
    /// Test `Secret` storing.
    func testSecretStoring() {
        let secret = Secret(cookies: [HTTPCookie(properties: [.name: "ds_user_id", .value: "A", .path: "A", .domain: "A"])!,
                                      HTTPCookie(properties: [.name: "csrftoken", .value: "B", .path: "B", .domain: "B"])!,
                                      HTTPCookie(properties: [.name: "sessionid", .value: "C", .path: "C", .domain: "C"])!])
        XCTAssert(
            secret.header
                .sorted(by: { $0.key < $1.key })
                .map { $0.key+$0.value }
                .joined() == "Cookieds_user_id=A; csrftoken=B; sessionid=C"
        )
        XCTAssert(secret.identifier == "A")
        secret.store(in: TransientStorage())
        XCTAssert(Secret.stored(with: "A", in: TransientStorage()) == nil)
        // Encode and decode.
        do {
            let encoded = try JSONEncoder().encode(secret)
            let decoded = try JSONDecoder().decode(Secret.self, from: encoded)
            XCTAssert(decoded.cookies == secret.cookies)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("TransientStorage", testTransientStorage),
        ("UserDefaultsStorage", testUserDefaultsStorage),
        ("Storage", testStorage),
        ("KeychainStorage", testKeychainStorage),
        ("Secret", testSecretStoring)
    ]
}
