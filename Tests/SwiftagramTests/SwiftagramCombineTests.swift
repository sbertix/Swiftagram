@testable import Swiftagram
import XCTest

#if canImport(Combine)
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class SwiftagramCombineTests: XCTestCase {
    /// The current cancellable.
    var requestCancellable: AnyCancellable?

    /// Test `Request`.
    func testStringRequest() {
        let expectation = XCTestExpectation()
        requestCancellable = Endpoint.generic
            .paginating()
            .publishOnce()
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let error): XCTFail(error.localizedDescription)
                default: break
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
        wait(for: [expectation], timeout: 5)
    }

    /// Test `Request`.
    func testRequest() {
        let expectation = XCTestExpectation()
        requestCancellable = Endpoint.generic
            .publish()
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let error): XCTFail(error.localizedDescription)
                default: break
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
        wait(for: [expectation], timeout: 5)
    }

    /// Test `Request` cancelling.
    func testCancel() {
        let expectation = XCTestExpectation()
        Endpoint.generic
            .publish()
            .handleEvents(receiveCancel: { expectation.fulfill() })
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .cancel()
        wait(for: [expectation], timeout: 5)
    }

    static var allTests = [
        ("Request", testRequest),
        ("Request.String", testStringRequest),
        ("Request.Cancel", testCancel)
    ]
}
#endif
