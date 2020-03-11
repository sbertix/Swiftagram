@testable import Swiftagram
import XCTest

final class SwiftagramResponseTests: XCTestCase {
    /// Test responses.
    func testResponse() {
        do {
            let value = [["Integer": 1,
                          "camel_case_string": "",
                          "bool": true,
                          "none": NSNull(),
                          "double": 2.0,
                          "url": "https://google.com"]]
            let data = try JSONSerialization.data(withJSONObject: value, options: [])
            let response = try Response(data: data)
            guard let array = response.array(), let first = array.first, response[0] == first else {
                return XCTFail("No element in response array.")
            }
            XCTAssert(first.integer.int() == 1, "Int is not `Int`.")
            XCTAssert(first.camelCaseString.string() == "", "String is not `String`.")
            XCTAssert(first["bool"].bool() == true, "Bool is not `Bool`.")
            XCTAssert(first.none == .none, "None is not `None`.")
            XCTAssert(Response(value).any() is [[String: Any]], "Check `any`")
            XCTAssert(!first.beautifiedDescription.isEmpty,
                      "Beautified description doesn't check out.")
            XCTAssert(first.dictionary()?["double"]?.double() == 2, "`Double` is not `Double`.")
            XCTAssert(first["url"].url() != nil, "`URL` is not `URL`.")
            try XCTAssert(Response(Response(["key": "value"]).data()).key.string() == "value", "`Data` is not `Data`.")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("Response", testResponse)
    ]
}
