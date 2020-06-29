//
//  Device.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 05/04/2020.
//

import CoreGraphics
import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// A `struct` holding reference to a custom Android device to be used for requests.
public struct Device: Equatable, Codable {
    /// The brand.
    public let brand: String
    /// The model.
    public let model: String
    /// The device model boot.
    public let modelBoot: String
    /// The CPU identifier.
    public let cpu: String

    /// The device GUID.
    public let deviceGUID: UUID
    /// The phone GUID.
    public let phoneGUID: UUID
    /// The goold AD ID.
    public let googleAdId: UUID

    /// The DPI.
    public let dpi: Int
    /// The resolution of the screen.
    public let resolution: CGSize

    /// The API version.
    public let api: String
    /// The OS version.
    public let version: String
    /// The OS release.
    public let release: String
    /// The application code.
    public let code: String

    /// The API user agent.
    public var apiUserAgent: String {
        return [
            "Instagram \(api)",
            "Android (\(release)/\(version);",
            "\(dpi)dpi;",
            "\(Int(resolution.width))x\(Int(resolution.height));",
            brand+";",
            model+";",
            modelBoot+";",
            cpu+";",
            "en_US;",
            code+")"
        ].joined(separator: " ")
    }
    /// The browser user agent.
    public var browserUserAgent: String {
        return [
            "Mozilla/5.0 (Linux; Android \(version); \(model))",
            "AppleWebKit/537.36 (KHTML, like Gecko)",
            "Chrome/79.0.3945.93 Mobile Safari/537.36"
        ].joined(separator: " ")
    }
    /// The device identifier.
    public var deviceIdentifier: String {
        return ["android-", deviceGUID.uuidString.replacingOccurrences(of: "-", with: "").prefix(16)].joined()
    }

    /// Init.
    /// - parameters:
    ///     - deviceGUID: An optional `UUID`. Defaults to `nil`, meaning a `UUID` will be inferred.
    ///     - phoneGUID: A valid `UUID`. Defaults to `.init()`.
    ///     - googleAdId: A valid `UUID`. Defaults to `.init()`.
    ///     - brand: A valid `String`.
    ///     - model: A valid `String`.
    ///     - modelBoot: A valid `String`.
    ///     - cpu: A valid `String`.
    ///     - dpi: A valid `Int`.
    ///     - resolution: A valid `CGSize`.
    ///     - api: A valid `String`. Defaults to `Constants.api`.
    ///     - version: A valid `String`. Defaults to `10.0.0`.
    ///     - release: A valid `String`. Defaults to `29`.
    ///     - code: A valid `String`. Defaults to `Constants.code`.
    public init(deviceGUID: UUID? = nil,
                phoneGUID: UUID = .init(),
                googleAdId: UUID = .init(),
                brand: String,
                model: String,
                modelBoot: String,
                cpu: String,
                dpi: Int,
                resolution: CGSize,
                api: String = Constants.appVersion,
                version: String = "10.0.0",
                release: String = "29",
                code: String = Constants.appVersionCode) {
        // prepare a fallback `UUID`.
        let fallbackGUID = UserDefaults.standard.string(forKey: "com.swiftagram.device").flatMap(UUID.init) ?? .init()
        #if canImport(UIKit)
        self.deviceGUID = UIDevice.current.identifierForVendor ?? fallbackGUID
        #else
        self.deviceGUID = fallbackGUID
        #endif
        // set other values.
        self.phoneGUID = phoneGUID
        self.googleAdId = googleAdId
        self.brand = brand
        self.model = model
        self.modelBoot = modelBoot
        self.cpu = cpu
        self.dpi = dpi
        self.resolution = resolution
        self.api = api
        self.version = version
        self.release = release
        self.code = code
        // store `UUID`.
        UserDefaults.standard.set(self.deviceGUID.uuidString, forKey: "com.swiftagram.device")
        UserDefaults.standard.synchronize()
    }
}

/// Default `Device`s.
public extension Device {
    /// The current `Device`. Defaults to `.note4X`.
    static var `default` = Device.redmiNote4X

    /// A European **Xiamoi Redmi Note 4x**.
    static let redmiNote4X = Device(brand: "Xiaomi",
                                    model: "Redmi Note 4X",
                                    modelBoot: "nikel",
                                    cpu: "mt6797",
                                    dpi: 480,
                                    resolution: .init(width: 1400, height: 3040))
}
