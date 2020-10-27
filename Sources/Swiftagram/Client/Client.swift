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

/// A `struct` holding reference to `Client` info.
public struct Client: Equatable, Codable, CustomStringConvertible {
    /// The default `Client`. Defaults to a **Samsung Galaxy S10**.
    /// - note: Replace it with your own for custom `Device` management.
    public static var `default` = Client.samsungGalaxyS20

    /// The application info.
    public let application: Application
    /// The device info.
    public let device: Device

    // MARK: Lifecycle

    /// Init.
    ///
    /// - parameters:
    ///     - application: A valid `Application`.
    ///     - device: A valid `Device`.
    public init(application: Application, device: Device) {
        self.application = application
        self.device = device
    }

    // MARK: Accessories

    /// The user agent.
    public var description: String {
        return "\(application.description) (\(device.description); \(application.code))"
    }

    /// The browser user agent.
    public var browserDescription: String { return device.browserDescription }
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
                                                          resolution: .init(width: 1080,
                                                                            height: 2277,
                                                                            scale: 2,
                                                                            dpi: 480)))

    /// An **iPhone 11 Pro Max**.
    static let iPhone11ProMax = Client(application: .iOS(),
                                       device: .iOS("iOS 14_0",
                                                    language: "en_US",
                                                    model: "iPhone12,5",
                                                    resolution: .init(width: 1242,
                                                                      height: 2688,
                                                                      scale: 3,
                                                                      dpi: 458)))

    #if canImport(UIKit)
    /// Return a custom iPhone device, computed from the current `UIDevice`.
    /// - note: If you're not on an iPhone, it returns `nil`.
    static var current: Client {
        return .init(application: .iOS(),
                     device: .iOS(UIDevice.current.systemVersion,
                                  language: NSLocale.current.identifier,
                                  model: UIDevice.current.model,
                                  resolution: .init(width: Int(UIScreen.main.bounds.width),
                                                    height: Int(UIScreen.main.bounds.height),
                                                    scale: Int(UIScreen.main.scale),
                                                    dpi: 458)))
    }
    #endif
}
