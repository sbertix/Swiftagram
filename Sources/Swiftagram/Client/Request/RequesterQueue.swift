//
//  RequesterQueue.swift
//  Swiftagram
//
//  Created by Stefano Bertagno on 08/03/2020.
//

import Foundation

public extension Requester {
    /// An `enum` identifying `DispatchQueue`s.
    enum Queue: Hashable {
        /// The current `DispatchQueue`.
        case current
        /// `DispatchQueue.main`
        case main
        /// The global `DispatchQueue` matching quality of service.
        case global(qos: DispatchQoS.QoSClass)

        /// Perform `block` on the correct `DispatchQueue`.
        internal func handle(_ work: @escaping () -> Void) {
            switch self {
            case .current: work()
            case .main: DispatchQueue.main.async(execute: work)
            case .global(let qos): DispatchQueue.global(qos: qos).async(execute: work)
            }
        }
    }
}
