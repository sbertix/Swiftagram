//
//  LegacyDevice.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 27/10/20.
//

import Foundation

/// A `struct` holding reference to `Device`s used before `4.2.0`.
///
/// This is kept in order to maintain backwards compatibility with `Secret`s.
/// Please keep in mind support for this might be removed in the future.
struct LegacyDevice: Codable {
    /// The brand.
    let brand: String
    /// The model.
    let model: String
    /// The device model boot.
    let modelBoot: String
    /// The CPU identifier.
    let cpu: String

    /// The device GUID.
    let deviceGUID: UUID
    /// The phone GUID.
    let phoneGUID: UUID
    /// The goold AD ID.
    let googleAdId: UUID

    /// The DPI.
    let dpi: Int
    /// The resolution of the screen.
    let resolution: [Double]

    /// The API version.
    let api: String
    /// The OS version.
    let version: String
    /// The OS release.
    let release: String
    /// The application code.
    let code: String
}
