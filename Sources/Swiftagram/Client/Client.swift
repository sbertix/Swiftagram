//
//  Client.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 27/10/20.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// A `struct` defining all possible information used to identify the software and hardware combination of a logged in user.
///
/// -  warning: `Client.default` is not guaranteed to remain the same.
public struct Client: Equatable, Codable, CustomStringConvertible {
    #if canImport(UIKit) && !canImport(WatchKit)
    /// The default `Client`. Defaults to `current`, if available, otherwise `iPhone11ProMax`.
    ///
    /// - note: Replace it with your own for custom `Device` management.
    /// -  warning: `Client.default` is not guaranteed to remain the same.
    public static var `default`: Client = .current ?? .iPhone11ProMax
    #else
    /// The default `Client`. Defaults to `iPhone11ProMax`.
    ///
    /// - note: Replace it with your own for custom `Device` management.
    /// -  warning: `Client.default` is not guaranteed to remain the same.
    public static var `default`: Client = .iPhone11ProMax
    #endif

    /// The application info.
    public let application: Application
    /// The device info.
    public let device: Device

    /// The user agent.
    public var description: String {
        "\(application.description) (\(device.description); \(application.code))"
    }
    /// The browser user agent.
    public var browserDescription: String { device.browserDescription }

    /// Init.
    ///
    /// - parameters:
    ///     - application: A valid `Application`.
    ///     - device: A valid `Device`.
    public init(application: Application, device: Device) {
        self.application = application
        self.device = device
    }
}

/// Extend `Client` to save custom implementations.
public extension Client {
    /// A **Samsung Galaxy S20**.
    static let samsungGalaxyS20 = Client(application: .android(),
                                         device: .android("29/10",
                                                          language: "en_US",
                                                          model: "SM-G981B",
                                                          brand: "samsung",
                                                          boot: "x1s",
                                                          cpu: "exynos990",
                                                          manufacturer: nil,
                                                          resolution: .init(width: 1_080,
                                                                            height: 2_277,
                                                                            scale: 2,
                                                                            dpi: 480)))

    /// An **iPhone 11 Pro Max**.
    static let iPhone11ProMax = Client(application: .iOS(),
                                       device: .iOS("iOS 14_0",
                                                    language: "en_US",
                                                    model: "iPhone12,5",
                                                    resolution: .init(width: 1_242,
                                                                      height: 2_688,
                                                                      scale: 3,
                                                                      dpi: 458)))

    #if canImport(UIKit) && !canImport(WatchKit)
    /// A custom iPhone device, based on the current `UIDevice`.
    ///
    /// - warning: If you're not running this on an iPhone (or an iPhone simulator), it will always evaluate to `nil`.
    static var current: Client? {
        // Prepare identifier for current model.
        let identifier: String
        #if targetEnvironment(simulator)
        guard let simulator = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] else { return nil }
        identifier = simulator
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        identifier = machineMirror.children.reduce(into: "") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            identifier += String(UnicodeScalar(UInt8(value)))
        }
        #endif
        guard identifier.contains("iPhone") else { return nil }
        return .init(application: .iOS(),
                     device: .iOS("iOS " + UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_"),
                                  language: NSLocale.current.languageCode ?? "en_US",
                                  model: identifier,
                                  resolution: .init(width: Int(UIScreen.main.nativeBounds.width),
                                                    height: Int(UIScreen.main.nativeBounds.height),
                                                    scale: Int(UIScreen.main.scale),
                                                    dpi: 458)))
    }
    #endif
}
