//
//  SwiftagramClientTests.swift
//  SwiftagramTests
//
//  Created by Stefano Bertagno on 27/10/20.
//

import Foundation
import XCTest

#if canImport(UIKit)
import UIKit
#endif

@testable import Swiftagram

final class SwiftagramClientTests: XCTestCase {
    /// Test an Android device.
    func testAndroid() {
        let device = Client.samsungGalaxyS20
        let description = ["Instagram 160.1.0.31.120 Android",
                           "(29/10; 480dpi; 1080x2277; samsung; SM-G981B; x1s; exynos990;",
                           "en_US; 246979827)"].joined(separator: " ")
        XCTAssert(device.description == description, "Invalid user agent")
    }

    /// Test an iOS device.
    func testIOS() {
        let device = Client.iPhone11ProMax
        let description = ["Instagram 160.1.0.31.120",
                           "(iPhone12,5; iOS 14_0; en_US; en-US; scale=3.00;",
                           "1242x2688; 246979827)"].joined(separator: " ")
        XCTAssert(device.description == description, "Invalid user agent")
    }
}
