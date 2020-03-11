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
        storage.removeAll()
        XCTAssert(storage.all().isEmpty, "Transient storage was actually not empty.")
    }
    /// Test `UserDefaultsStorage` flow as `[Storage]`.
    func testStorage() {
        let storage = [UserDefaultsStorage()]
        storage.removeAll()
        XCTAssert(storage.all().isEmpty, "Storage did not empty")
        storage.store(response)
        XCTAssert(storage.find(matching: response.id) != nil, "Storage did not retrieve cached response.")
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
        XCTAssert(storage.find(matching: response.id) != nil, "Storage did not retrieve cached response.")
        XCTAssert(storage.remove(matching: response.id) != nil, "Transient storage was actually not empty.")
        XCTAssert(storage.all().isEmpty, "Transient storage was actually not empty.")   // Always `nil` during test.
        storage.removeAll()
        XCTAssert(storage.all().isEmpty, "Transient storage was actually not empty.")
    }
    /// Test `Secret` storing.
    func testSecretStoring() {
        let secret = Secret(identifier: HTTPCookie(properties: [.name: "A", .value: "A", .path: "A", .domain: "A"])!,
                            crossSiteRequestForgery: HTTPCookie(properties: [.name: "B", .value: "B", .path: "B", .domain: "B"])!,
                            session: HTTPCookie(properties: [.name: "C", .value: "C", .path: "C", .domain: "C"])!)
        XCTAssert(
            secret.headerFields
                .sorted(by: { $0.key < $1.key })
                .map { $0.key+$0.value }
                .joined() == "CookieA=A; B=B; C=C"
        )
        XCTAssert(secret.id == "A")
        secret.store(in: TransientStorage())
        XCTAssert(Secret.stored(with: "A", in: TransientStorage()) == nil)
        // Encode and decode.
        do {
            let encoded = try JSONEncoder().encode(secret)
            let decoded = try JSONDecoder().decode(Secret.self, from: encoded)
            XCTAssert(decoded.id == secret.id)
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
